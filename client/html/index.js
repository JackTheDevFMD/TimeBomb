$(function () {
	function display(bool) {
		if (bool) {
			$('#container').show();
		} else {
			$('#container').hide();
		}
	}

	display(false);

	// Excape exit

	document.addEventListener('keydown', function (event) {
		if (event.keyCode == 27) {
			$.post(
				'https://TimeBomb/exit',
				JSON.stringify({
					text: 'escape',
				})
			);
			return;
		}
	});

	// Submit button

	$('#hashButton').click(function () {
		let time = document.getElementById('bombTimer').innerText;
		document.getElementById('bombTimer').innerHTML = '00:00';

		$.post(
			'https://TimeBomb/exit',
			JSON.stringify({
				text: time,
			})
		);
		return;
	});

	// Button click

	$('#starButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#zeroButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#hashButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});

	$('#oneButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#twoButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#threeButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});

	$('#fourButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#fiveButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#sixButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});

	$('#sevenButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#eightButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});
	$('#nineButton').click(function () {
		$.post('https://TimeBomb/buttonPress', JSON.stringify({}));
		return;
	});

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
	var currentTime = document.getElementById('bombTimer').innerText;
	var newTime = '00:00';

	if (currentTime === '00:00') {
		var newTime = setCharAt(currentTime, 4, button);
	} else if (button === '*') {
		newTime = '00:00';
	} else if (button === '#') {
		// Plant bomb
		newTime = currentTime;
		document.getElementById('bombText').innerHTML = 'armed';
	} else {
		var numbers = [
			currentTime[0],
			currentTime[1],
			':',
			currentTime[3],
			currentTime[4],
		];

		for (let i = 0; i < 5; i++) {
			if (numbers[0] == '0') {
				if (numbers[i] != '0' && numbers[i] != ':') {
					// Shifting the numbers

					var temp = numbers[i];
					var newPos = 0;

					if (i - 1 == 2) {
						newPos = i - 2;
					} else {
						newPos = i - 1;
					}

					newTime = setCharAt(newTime, newPos, temp);
				}
			}
		}

		// Adding the new number

		if (numbers[0] == '0') {
			if (newPos + 1 === 2) {
				newPos = newPos + 2;
			} else {
				newPos = newPos + 1;
			}

			newTime = setCharAt(newTime, newPos, button);
		} else {
			newTime = currentTime;
		}
	}

	document.getElementById('bombTimer').innerHTML = newTime;
}

function setCharAt(str, index, chr) {
	if (index > str.length - 1) return str;
	return str.substring(0, index) + chr + str.substring(index + 1);
}
