$( document ).ready(function() {
	
	$("#hikes").load("/hikes/1")
	
	if ( $(".hikeBox").length > 99 ) {
		$("a:last").on( "click", function(event){
			event.preventDefault();
			var url = $("a:last").attr("href");
			var newDiv = document.createElement("div");
			$(newDiv).load(url);
			$("a:last").remove();
			stuff = $("#hikes")
			newDiv.contents().appendTo( stuff );
		});
	}
	else {
		$("a:last").remove();
	}
	
	
	
	
});