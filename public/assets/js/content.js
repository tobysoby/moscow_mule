function setContent(index) {
	$.ajax({
		url: 'http://localhost:4567/features/' + index,
		success:function(data){
			$(".page-header").html("<h1>" + data.feature_title + "</h1>");
			var html_string = "";
			//set a table of contents
			html_string = html_string + "<div class='list-group'>";
			$.each(data.feature_scenarios, function(index,value) {
				html_string = html_string + "<a href='#scenario_" + index + "' class='list-group-item'>" + value.title + "</a>";
			})
			html_string = html_string + "</div>";
			//set the scenarios
			$.each(data.feature_scenarios, function(index,value) {
				html_string = html_string + "<div id='scenario_" + index + "' class='panel panel-default'><!-- Default panel contents --><div class='panel-heading'>" + value.title + "</div><div class='panel-body'><p>" + value.description + "</p></div><!-- List group --><ul class='list-group'>"
				$.each(value.steps, function(index2,value_step) {
					html_string = html_string + "<li class='list-group-item'>" + value_step + "</li>"
				});
				html_string = html_string + "</ul></div>"
			});
			$(".content").html(html_string);
		}
	});
}