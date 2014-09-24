$(document).ready(function() {
    $('.data_item').dblclick(function() {
	$(this).toggleClass('edit_false');
	$(this).toggleClass('edit_true');
    });
});

