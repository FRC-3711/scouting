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
      
      field :_id, type: String
      field :name, type: String
      field :group, type: String
      field :type, type: String
      embeds_many :attroptions
    end
   
    class AttrOption
      include Mongoid::Document
      
      field :value, type: String
      field :text, type: String
      embedded_in :attribute
    end

    class Team
      include Mongoid::Document
      
      field :_id, type: Integer
      field :name, type: String
      field :quick_take, type: String
    end
  end
  
  module Controllers
    class Index
      def get
        @teams = Team.all
        render :index
      end
    end
    
    class TeamX
      def get(id)
        @team = Team.first( :_id => id.to_i )
        render :team
      end
    end
    
    class TeamEdit
      def get
        @edit = true
        render :team
      end

      def post
        @content = @input.content
      end
    end
    
    class TeamXEdit
      def get(id)
        @team = Team.first( :_id => id.to_i )
        @attributes = Attribute.all
        @edit = true
        render :team
      end
      
      def post
        @content = @input.content
      end
    end
    
    class TeamEditX
      def get(id)
        @team = Team.first( :_id => id.to_i )
        @attributes = Attribute.all
        @edit = true
        render :team
      end
      
      def post
        @content = @input.content
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
              opt_array.push(AttrOption.new(:value => o.split(',')[0].strip, :text => o.split(',')[1].strip))
            end
        att = Attribute.new(:_id => @input.att_id, :name => @input.att_name, :type => @input.att_type, :options => opt_array)
        att.save

        redirect Attributes
      end
    end
  end
  
  module Views
    def layout
      html do
        head do
          title "scouting by 3711"
          link :rel => "stylesheet", :type => "text/css", :href => "/css/scouting.css"
          link :rel => "stylesheet", :type => "text/css", :media => "handheld", :href => "/css/scouting-mobile.css"
        end
        body { self << yield }
      end
    end
    
    def index
      @teams.each do |t|
              p do
                a :href => R(TeamX, t._id) do t._id end
                text " "
                a :href => R(TeamXEdit, t._id) do "Edit" end
              end
            end
    end

    def team
      if @edit
        form :action => R(TeamX, @team), :method => :post do
                                                   team_header(@edit)
                                                   team_actions(@edit)
                                                   team_attributes(@edit)
                                                   team_footer(@edit)
                                                 end
      else
        team_header(@edit)
        team_actions(@edit)
        team_attributes(@edit)
        team_footer(@edit)
      end
    end
    
    def team_header(edit)
      div.team_header!.header do
           h1 do
             if edit           
               "Team&nbsp;" + input.team_number!.team_number( :type => "number", :value => @team._id )
             else
               "Team #{@team._id}"
             end
           end
           h2 do
             if edit
               input.team_name!.team_name( :type => "text", :value => @team.name )
             else
               @team.name
             end
           end
           if edit
             label :for => "quick_take" do
               "Quick Take:&nbsp;"
             end
             select.quick_take! do
                     quick_take_options
                   end
           else
             text "Quick Take: #{@team.quick_take}"
           end
           button.start_match! "Start Match"
         end
    end
    
    def team_actions(edit)
      div.robot_actions!.actions do
           h2 "TeleOp"
           @team.teleop.each do |ax|
                         if edit
                           p do
                             label :for => ax[0] do "#{ax[0]}&nbsp;" end
                             select :id => ax[0] do
                               option :value => "unknown", :default => "true"
                             end
                           end
                         else
                           p do
                             text "#{ax[0]}: #{ax[1]}"
                           end
                         end
                       end
         end
    end

    def team_attributes(edit)
      div.robot_attributes!.attributes do
           h2 "General"
         end
    end
    
    def team_footer(edit)
      div.team_footer!.footer do
           if edit
             input :type => :submit, :value => "Save"
           end
         end
    end

    def attributes
      if (@attributes)
        @attributes.each do |at|
                     p do
                       text "#{at.name}"
                     end
                   end
      end
      
      form :action => R(Attributes), :method => "post" do
                                  p do
                                    label :for => "att_name" do "Name&nbsp;" end
                                    input.att_name!.att_input :name => "att_name", :type => "text"
                                    label :for => "att_id" do "&nbsp;ID&nbsp;" end
                                    input.att_id!.att_input :name => "att_id", :type => "text"
                                    label :for => "att_section" do "&nbsp;Section&nbsp;" end
                                    select.att_section!.att_input :name => "att_section" do
                                             option :value => "general", :default => "true" do "General" end
                                             option :value => "teleop" do "TeleOp" end
                                             option :value => "autonomous" do "Autonomous" end
                                           end
                                    label :for => "att_type" do "&nbsp;Type&nbsp;" end
                                    select.att_type!.att_input :name => "att_type" do
                                             option :value => "string", :default => "true" do "String" end
                                             option :value => "picklist" do "Picklist" end
                                             option :value => "radio" do "Radio button" end
                                           end
                                    br
                                    label :for => "att_options" do "&nbsp;Options&nbsp;" end
                                    br
                                    textarea.att_options!.att_input :name => "att_options"
                                    input :type => "submit", :value => "Add"
                                  end
                                end
    end
    
    def quick_take_options
      option :value => "unknown", :default => "true" do "Not scouted" end
      option :value => "must" do "MUST pick" end
      option :value => "fair" do "Fair pick" end
      option :value => "poor" do "Poor pick" end
      option :value => "nooo" do "DO NOT pick" end
    end
  end
end

Scouting.create
