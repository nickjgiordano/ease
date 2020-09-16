function storePosition() {
	var yOffset = window.pageYOffset;
	document.cookie = yOffset;
}
function scrollPosition() {
	var yOffset = document.cookie;
	window.scrollTo(0, yOffset);
}
function filter(view, column, criterion) {
	criterion = criterion.value;
    window.location.href = encodeURI("index.php?view=" + view + "&filter=" + column + "&criterion=" + criterion);
}