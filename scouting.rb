require 'camping'
require 'mongoid'

Camping.goes :Scouting

module Scouting
  def self.create
    Mongoid.load!('mongoid.yml')
  end
  
  module Models
    class Attribute
      include Mongoid::Document
      
      field :_id, type: String, default: ->{ name.strip.downcase.gsub(/\s+/, '_') }
      field :name, type: String
      field :group, type: String
      field :type, type: String

      def self.quick_take
        if (!where( :group => "quicktake" ).exists?)
          #quick take is intended to be a standard field, and the group isn't made available on the admin page, so add it if it doesn't exist
          new(
            :_id => "quick_take",
            :name => "Quick Take",
            :group => "quicktake",
            :type => "picklist",
            :options => [ 
              { :value => "must", :text => "MUST pick" }, 
              { :value => "fair", :text => "Fair pick" },
              { :value => "poor", :text => "Poor pick" },
              { :value => "nooo", :text => "DO NOT pick" }
            ]
          ).save
        end
        quick_take = Attribute.where( :group => "quicktake" ).first
        return quick_take
      end

      def self.autonomous
        return where( :group => 'autonomous' )
      end

      def self.general
        return where( :group => 'general' )
      end
      
      def self.teleop
        return where( :group => 'teleop' )
      end

      store_in collection: 'attributes'
    end

    class Team
      include Mongoid::Document
      
      field :_id, type: Integer
      field :name, type: String
      field :attrs, type: Hash, default: Hash.new
      
      store_in collection: 'teams'
    end
  end
  
  module Controllers
    class Index
      def get
#        @teams = Team.count > 0 ? Team.all.asc( :_id ) : nil
        render :index
      end
    end
    
    class TeamN
      def get(id)
        @team_number = id.to_i
        @team = Team.where( :_id => @team_number ).first
        @attributes = Attribute.all
        if @team
          render :team
        else
          redirect TeamNEdit, @team_number
        end
      end
    end
    
    class TeamEdit
      def get
        @edit = true
        @team = Team.new
        @attributes = Attribute.all
        render :team
      end
      
      def post
        attrs = Hash.new
        Attribute.all.each do |at|
                       attrs[at._id] = @input[at._id]
                     end
        team = Team.new(
                 :name => @input.team_name,
                 :attrs => attrs
               )
        team._id = @input.team_number
        team.upsert

        redirect TeamN, team._id
      end
    end
    
    class TeamNEdit
      def get(id)
        @team_number = id.to_i
        @team = Team.where( :_id => @team_number ).first_or_initialize
        if (!@team._id)
          @team._id = @team_number
        end
        @attributes = Attribute.all
        @edit = true
        render :team
      end
    end
    
    class TeamEditN
      def get(id)
        @team_number = id.to_i
        @team = Team.where( :_id => @team_number ).first_or_initialize
        if (!@team._id)
          @team._id = @team_number
        end
        @attributes = Attribute.all
        @edit = true
        render :team
      end
    end
    
    class Attributes
      def get
        @attributes = Attribute.all
        render :attributes
      end
      
      def post
        opts = @input.att_options.split("\r\n")
        opt_array = []
        opts.each do |o|
              opt_array.push( { :value => o.split(',')[0].strip, :text => o.split(',')[1].strip } )
            end
        att = Attribute.new(
                :_id => @input.att_id,
                :name => @input.att_name,
                :type => @input.att_type,
                :group => @input.att_group,
                :options => opt_array
              )
        att.upsert
        
        redirect Attributes
      end
    end
  end
  
  module Views
    def layout
      html do
        head do
          title "scouting by 3711"
#          meta :name => "viewport", :content => "width=device-width, initial-scale=1.0, user-scalable=no"
          link :rel => "stylesheet", :type => "text/css", :href => "/css/scouting.css"
#          link :rel => "stylesheet", :type => "text/css", :href => "/css/scouting-mobile.css"
          script :src => "js/jquery-2.1.0.js", :type => "text/javascript"
          script :src => "js/underscore.js", :type => "text/javascript"
          script :src => "js/backbone.js", :type => "text/javascript"
          script :src => "js/backbone-faux-server.js", :type => "text/javascript"
          script :src => "js/faux-server.js", :type => "text/javascript"
          script :src => "js/main.js", :type => "text/javascript"
        end
        body { self << yield }
      end
    end
    
#    def index
#      if (@teams)
#        @teams.each do |t|
#                p do
#                  a :href => R(TeamN, t._id) do t._id end
#                  text " "
#                  a :href => R(TeamNEdit, t._id) do "Edit" end
#                end
#              end
#      end
#      p do
#        a :href => R(TeamEdit) do "Add New" end
#      end
#    end

    def index
      div :id => "backbone-app" do "Loading..." end
      script :id => "team-list-template", :type => "text/template" do
                                            backbone_team_list_template()
                                          end
      script :id => "team-template", :type => "text/template" do
                                       backbone_team_template()
                                     end
    end

    def team
      form :action => R(TeamEdit), 
      :method => :post do
                team_header(@edit)
                team_actions(@edit)
                team_attributes(@edit)
                team_footer(@edit)
              end
    end
    
    def team_header(edit)
      edit_s = edit ? 'true' : 'false'
      div.team_header!.header do
           h1 do
             span :class => "data_item edit_#{edit_s}" do
                   text "Team "
                   input.team_number!( :class => "team_number attr_input", :type => "number", :name => "team_number", :value => @team._id)
                   span.attr_value @team._id
                 end
           end
           h2 do
             span :class => "data_item edit_#{edit_s}" do
               input.team_name!( :class => "team_name attr_input", :type => "text", :name => "team_name", :value => @team.name )
               span.attr_value @team.name
             end
           end
           attribute_input(@attributes.quick_take, @team, edit)
         end
    end
    
    def team_actions(edit)
      div.teleop!.actions do
           h2 "TeleOp"
           @attributes.teleop.each do |at|
                               p do
                                 attribute_input(at, @team, edit)
                               end
                             end
         end
      div.autonomous!.actions do
           h2 "Autonomous"
           @attributes.autonomous.each do |at|
                                   p do
                                     attribute_input(at, @team, edit)
                                   end
                                 end
         end
    end
    
    def team_attributes(edit)
      div.general!.attributes do
           h2 "General"
           @attributes.general.each do |at|
                                p do
                                  attribute_input(at, @team, edit)
                                end
                              end
         end
    end
    
    def team_footer(edit)
      div.team_footer!.footer do
           if edit
             input :type => :submit, :value => "Save"
           else
             a :href => R(TeamNEdit, @team._id) do "Edit" end
           end
         end
    end

    def attributes
      if (@attributes.teleop.exists?)
        h2 "TeleOp"
        @attributes.teleop.each do |at|
                            p do
                              text "#{at.name} (#{at._id}) / #{at.type}"
                            end
                          end
      end
      if (@attributes.autonomous.exists?)
        h2 "Autonomous"
        @attributes.autonomous.each do |at|
                                p do
                                  text "#{at.name} (#{at._id}) / #{at.type}"
                                end
                              end
      end
      if (@attributes.general.exists?)
        h2 "General"
        @attributes.general.each do |at|
                             p do
                               text "#{at.name} (#{at._id}) / #{at.type}"
                             end
                           end
      end

      form :action => R(Attributes), :method => "post" do
                                       p do
                                         label :for => "att_name" do "Name&nbsp;" end
                                         input.att_name!.att_input :name => "att_name", :type => "text"
                                         label :for => "att_group" do "&nbsp;Group&nbsp;" end
                                         select.att_group!.att_input :name => "att_group" do
                                                  option :value => "general", :default => "true" do "General" end
                                                  option :value => "teleop" do "TeleOp" end
                                                  option :value => "autonomous" do "Autonomous" end
                                                end
                                         label :for => "att_type" do "&nbsp;Type&nbsp;" end
                                         select.att_type!.att_input :name => "att_type" do
                                                  option :value => "string", :default => "true" do "String" end
                                                  option :value => "picklist" do "Picklist" end
                                                  option :value => "radio" do "Radio button" end
                                                  option :value => "checkbox" do "Checkbox" end
                                                end
                                         br
                                         label :for => "att_options" do "&nbsp;Options&nbsp;" end
                                         br
                                         textarea.att_options!.att_input :name => "att_options"
                                         input :type => "submit", :value => "Add"
                                       end
                                     end
    end
  end

  module Helpers
    def backbone_team_template
      return "<div id='team-header' class='header'>\r\n\t<h1>Team <%= id %></h1>\r\n\t<h2><%= name %></h2>\r\n\tQuick Take: <%= quick_take %>\r\n</div>"
    end

    def backbone_team_list_template
      return "<% _.each(data, function(item) { %>\r\n\t<p>\r\n\t\t<a href='teams/<%= item.id %>'><%= item.id %>: <%= item.name %></a>\r\n\t\t<a href='teams/<%= item.id %>/edit'>Edit</a>\r\n\t</p>\r\n<% }); %>\r\n<p>\r\n\t<a href='teams/edit'>Add New</a>\r\n</p>"
    end

    def attribute_input(at, team, edit)
      edit_s = edit ? 'true' : 'false'
      span :class => "data_item edit_#{edit_s}" do
            if ( at.type == 'checkbox' )
              if (team.attrs[at._id] == 'yes')
                input.attr_input :type => 'checkbox', :value => 'yes', :id => at._id, :name => at._id, :checked => 'true'
              else
                input.attr_input :type => 'checkbox', :value => 'yes', :id => at._id, :name => at._id
              end
            end
            label :for => at._id do "#{at.name}: " end
            if ( at.type != 'checkbox' )
              case at.type
              when 'picklist'
                select.attr_input :id => at._id, :name => at._id do
                                                              option :value => "unknown", :default => "true"
                                                              at.options.each do |opt|
                                                                          if (team.attrs[at._id] == opt['value'])
                                                                            option :value => opt['value'], :selected => 'true' do opt['text'] end
                                                                          else
                                                                            option :value => opt['value'] do opt['text'] end
                                                                          end
                                                                        end
                                                            end
              when 'radio'
                at.options.each do |opt|
                            if (team.attrs[at._id] == opt['value'])
                              input.attr_input :type => "radio",
                              :id => "#{at._id}_#{opt['value']}", 
                              :name => at._id,
                              :value => opt['value'],
                              :checked => 'true'
                              label :for => "#{at._id}_#{opt['value']}" do opt['text'] end
                            else
                              input.attr_input :type => "radio", 
                              :id => "#{at._id}_#{opt['value']}", 
                              :name => at._id,
                              :value => opt['value']
                              label :for => "#{at._id}_#{opt['value']}" do opt['text'] end
                            end
                          end
              else
                input.attr_input :type => 'text', :id => at._id, :name => at._id, :value => team.attrs[at._id]
              end
            end
            value = ''
            if (at.type == 'string')
              value = team.attrs[at._id]
            elsif (at.type == 'checkbox')
              value = team.attrs[at._id] == 'yes' ? 'Yes' : 'No'
            else
              at.options.each do |opt|
                          if opt['value'] == team.attrs[at._id]
                            value = opt['text']
                            break
                          end
                        end
            end
            span.attr_value "#{value}"
      end
    end
  end
end

Scouting.create
