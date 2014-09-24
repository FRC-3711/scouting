(function() {
var teams;

fauxServer
	.post("teams", function(context) {
		teams[context.id] = context;
		return teams[context.id];
	}).get("teams", function(context) {
		return teams;
	}).get("teams/:id", function(context, id) {
		return teams[id];
	}).put("teams/:id", function(context, id) {
		teams[id] = context;
		return teams[id];
	}).del("teams/:id", function(context, id) {
		delete teams[id];
	});

teams = [
	{
		id: 3711,
		name: 'Iron Mustangs',
		quick_take: 'fair',
		teleop: {
			picks_up: 'fast',
			kicks_out: 'fast',
			shoots_hi: 'eh',
			shoots_lo: 'solid',
			shoots_truss: 'to_hp',
			catches: 'from_hp',
			teamwork: 'good'
		}, autonomous: {
			moves_into_zone: 'yes',
			shoots_auto: 'no',
			misses: false,
			hot_goal: false,
			two_ball: false
		}, general: {
			driving_speed: 'med',
			pushable: true,
			top_heavy: false,
			gets_in_the_way: false,
			plays_good_defense: true,
			truss_to_hp: true
		}
	},
	{
		id: 4061,
		name: 'SciBorgs',
		quick_take: 'must',
		teleop: {
			picks_up: 'fast',
			kicks_out: 'fast',
			shoots_hi: 'solid',
			shoots_lo: 'solid',
			shoots_truss: 'to_field',
			catches: 'from_hp',
			teamwork: 'good'
		}, autonomous: {
			moves_into_zone: 'yes',
			shoots_auto: 'high',
			misses: false,
			hot_goal: false,
			two_ball: true
		}, general: {
			driving_speed: 'fast',
			pushable: false,
			top_heavy: false,
			gets_in_the_way: false,
			plays_good_defense: true,
			truss_to_hp: true
		}
	}
];
})();
