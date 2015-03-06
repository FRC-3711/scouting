var validateTeam = function(attrs, options) {
	if (typeof attrs.id != 'Number') {
		return 'You must specify the team number.';
	}
}

$(document).ready(function() {
	var Team,
		TeamList,
		TeamView,
		TeamListView,
		ScoutingApp;

	Team = Backbone.Model.extend({
		validate: validateTeam
	});

	TeamList = Backbone.Collection.extend({
		model: Team,
		url: 'teams'
	});

	TeamView = Backbone.View.extend({
		model: Team,
		el: 'div#backbone-app',
		template: $('#team-template').html(),
		render: function() {
			tmpl = _.template(this.template, { data: this.model.toJSON() });
			this.$el.html(tmpl);
			return this;
		}
	});

	TeamListView = Backbone.View.extend({
		el: 'div#backbone-app',
		initialize: function() {
			this.collection = new TeamList();
		},
		template: $('#team-list-template').html(),
		render: function() {
			this.collection.fetch();
			if (this.collection.models.length === 0) {
				this.$el.html('Loaded. Nothing to display!');
			} else {
				var tmpl = _.template(this.template, { data: this.collection.toJSON() });
				this.$el.html(tmpl);
			}
			return this;
		}
	});

	ScoutingApp = Backbone.Router.extend({
		routes: {
			"teams" : "teamList",
			"teams/:id" : "team",
			"teams/(:id/)edit" : "teamEdit",
			"teams/edit(/:id)" : "teamEdit"
		},
		
		teamList: function() {
			var teamListView = new TeamListView();
			teamListView.render();
		},
		team: function(teamId) {
			var team = new TeamView({model: Team, id: teamId});
			teamView.render();
		}
	});

	router = new ScoutingApp();
	var teamListView = new TeamListView();
	teamListView.render();
	Backbone.history.start({pushState: true});
	$('a').click(function(e) {
		router.navigate($(this).attr('href'), {trigger: true});
		e.preventDefault();
	});
});