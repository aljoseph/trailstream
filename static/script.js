$( document ).ready(function() {
	
	$(".hikes").load("/hikes/1")
	
	if ( $(".hikes .col-md-4").length > 98 ) {
		$(".hikes:last a:last").on( "click", function(event){
			event.preventDefault();
			var url = $(".hikes:last a:last").attr("href");
			var newDiv = document.createElement("div");
			$(newDiv).addClass("container-fluid hikes");
			$(newDiv).load(url);
			$(".hikes:last").after( $(newDiv) );
		});
	}
	else {
		$("a.btn").remove();
	}
	
});