$(function () {
	function display(bool) {
		if (bool) {
			$('#container').show();
		} else {
			$('#container').hide();
		}
	}

	display(false);

	window.addEventListener('message', function (event) {
		var item = event.data;
		if (item.type === 'ui') {
			if (item.status == true) {
				display(true);
			} else {
				display(false);
			}
		}
	});
});

function buttonPress(button) {
	alert(button);
}
