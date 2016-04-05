function setContent(index) {
	$.ajax({
		url: 'http://localhost:4567/features/' + index,
		success:function(data){
			$(".page-header").html("<h1>" + data.feature_title + "</h1>");
			var html_string = "";
			//set a table of contents
			html_string += "<div class='list-group'>";
			$.each(data.feature_scenarios, function(index,value) {
				html_string += "<a href='#scenario_" + index + "' class='list-group-item'>" + value.title + "</a>";
			})
			html_string += "</div>";
			//set the scenarios
			$.each(data.feature_scenarios, function(index,value) {
				html_string += "<div id='scenario_" + index + "' class='panel panel-default'><!-- Default panel contents --><div class='panel-heading'>" + value.title
				//add the tags as labels
				$.each(value.tags, function(index2, value_tag) {
					html_string += "<span class='label label-default'>" + value_tag + "</span>"
				})
				html_string += "</div><div class='panel-body'><p>" + value.description + "</p></div><!-- List group --><ul class='list-group'>"
				$.each(value.steps, function(index2,value_step) {
					html_string = html_string + "<li class='list-group-item'>" + value_step + "</li>"
				});
				html_string += "</ul></div>"
			});
			$(".content").html(html_string);
		}
	});
}

function setContent_taglist(target, index) {
	$.ajax({
		url: 'http://localhost:4567/tags/' + target + '/' + index,
		success:function(data){
			$(".page-header").html("<h1>" + data.tag + "</h1>");
			var html_string = "";
			//set a table of contents
			html_string += "<div class='list-group'>";
			$.each(data.scenario_ids, function(index,value) {
				var index_minus = value.indexOf("-");
				console.log(value.substring(index_minus+1, value.length-1));
				html_string += "<a href='#scenario_" + value.substring(index_minus+1, value.length) + "' onclick='setContent(" + value.substring(0, index_minus) + ");return false;' class='list-group-item'>" + data.scenario_titles[index] + "</a>";
				//index_value = value;
			});
			html_string += "</div>";
			$(".content").html(html_string);
    		//location.href = "#scenario_"+index_value.substring(index_minus+1, index_value.length); 
		}
	});
}