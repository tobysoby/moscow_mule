var moscowMuleApp = angular.module('moscowMuleApp', [
	'ngRoute'
]);

moscowMuleApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/showfeature', {
		templateUrl: 'partials/show_feature.html',
		controller: 'FeaturesCtrl'
	}).
	when('/showscenario', {
		templateUrl: 'partials/show_scenario.html',
		controller: 'FeaturesCtrl'
	}).
	when('/runtests', {
		templateUrl: 'partials/run_tests.html',
		controller: 'RunTestsCtrl'
	}).
	when('/showtags', {
		templateUrl: 'partials/show_tags.html',
		controller: 'FeaturesCtrl'
	}).
	when('/showresults', {
		templateUrl: 'partials/show_results.html',
		controller: 'RunTestsCtrl'
	}).
	when('/', {
		templateUrl: 'partials/home.html',
		controller: 'FeaturesCtrl'
	}).
	when('/uploadtests', {
		templateUrl: 'partials/upload_tests.html',
		controller: 'FeaturesCtrl'
	}).
	when('/about', {
		templateUrl: 'partials/about.html',
		controller: 'FeaturesCtrl'
	});
}]);

moscowMuleApp.controller('FeaturesCtrl', function($scope, $http){

	$scope.testsToRun = [];

	$http.get('http://localhost:1234/api/features').then(function(featuresResponse) {
		$scope.features = featuresResponse.data;
	});
	$http.get('http://localhost:1234/api/scenarios').then(function(featuresResponse) {
		$scope.scenarios = featuresResponse.data;
	});
	$http.get('http://localhost:1234/api/tags/testers').then(function(featuresResponse) {
		$scope.tags_testers = featuresResponse.data;
	});
	$http.get('http://localhost:1234/api/tags/testplans').then(function(featuresResponse) {
		$scope.tags_testplans = featuresResponse.data;
	});
	$http.get('http://localhost:1234/api/tags/platforms').then(function(featuresResponse) {
		$scope.tags_platforms = featuresResponse.data;
	});
	$http.get('http://localhost:1234/api/tags/global').then(function(featuresResponse) {
		$scope.tags_global = featuresResponse.data;
	});
	$scope.setFeature = function(feature) {
		$scope.currentFeature = feature;
		if (feature["feature"]["children"][0]["type"] === "Background") {
			$scope.background = feature["feature"]["children"][0]
			feature["feature"]["children"].shift()
		} else {
			$scope.background = null
		}
		$scope.scenariosInFeature = feature["feature"]["children"];
	};
	$scope.setScenario = function(scenario) {
		$scope.$parent.currentScenario = scenario;
	};
	$scope.addToTestRun = function(scenario) {
		//if the scenario is not yet in the scenarios to run array
		if ($scope.$parent.testsToRun.indexOf(scenario) == -1) {
			//add it!
			$scope.$parent.testsToRun.push(scenario);
		}
		$scope.testsToRun = $scope.$parent.testsToRun;
		$scope.$applyAsync();
	};
	$scope.startRunningTests = function() {
		//set the test_index
		$scope.test_index = -1;
		//set run_test_state
		$scope.runTestState = 0;
	};
	$scope.setTag = function(tag) {
		//get the scenarios
		var scenariosToShowIds = tag.scenarios;
		$scope.scenariosToShow = [];
		for (var i = 0; i < scenariosToShowIds.length; i++) {
			$scope.scenariosToShow.push($scope.scenarios[tag.scenarios[i][1]]);
		}
	};
	$scope.saveTests = function (tests) {
			$scope.toJSON = '';
			$scope.toJSON = angular.toJson(tests);
			var blob = new Blob([$scope.toJSON], { type:"application/json;charset=utf-8;" });			
			var downloadLink = angular.element('<a></a>');
                        downloadLink.attr('href',window.URL.createObjectURL(blob));
                        downloadLink.attr('download', 'testRun.json');
			downloadLink[0].click();
		};
	$scope.uploadTests = function() {
		var f = document.getElementById('file').files[0],
			r = new FileReader();
		r.onloadend = function(e) {
			var data = e.target.result;
			testsToRun = angular.fromJson(data);
			for (i = 0; i<testsToRun.length; i++) {
				$scope.addToTestRun(testsToRun[i]);
			}
		}
		r.readAsBinaryString(f);
	};
	$scope.addAllToTestrun = function(scenarios) {
		for (i = 0; i<scenarios.length; i++) {
			$scope.addToTestRun(scenarios[i]);
		}
	};
});

moscowMuleApp.controller('RunTestsCtrl', function($scope){
	//set the text of the button on the test_page
	$scope.buttonStartTestsText = "Start running tests";
	$scope.buttonLastTestText = "Last test";
	$scope.buttonNextTestText = "Next test";
	$scope.buttonShowResultsText = "Show results";
	$scope.setLastTest = function() {
		//get the current test_index
		test_index = $scope.test_index;
		//raise the test_index
		test_index -= 1;
		//set the test
		$scope.setTest(test_index);
		//write the test_index into the scope
		$scope.test_index = test_index;
	};
	$scope.setNextTest = function() {
		//get the current test_index
		test_index = $scope.test_index;
		//raise the test_index
		test_index += 1;
		//set the test
		$scope.setTest(test_index);
		//write the test_index into the scope
		$scope.test_index = test_index;
	};
	$scope.setTest = function(test_index) {
		//get the scenario which should be tested
		$scope.scenarioToTest = $scope.testsToRun[test_index];
		//set the buttons text
		if (test_index < $scope.testsToRun.length-1) {
			$scope.runTestState = 1
		}
		else {
			$scope.runTestState = 2
		}
	};
	$scope.checkIfTestIndexMinusOne = function() {
		if ($scope.test_index == -1 || $scope.test_index == null) {
			return true;
		}
	};
	$scope.showResults = function() {
		for (var i = 0; i < $scope.testsToRun.length; i++) {
			if ($scope.testsToRun[i].result == "true") {
				$scope.testsToRun[i].result_show = "(/)";
			}
			if ($scope.testsToRun[i].result == "false") {
				$scope.testsToRun[i].result_show = "(x)";
			}
			// for jira: if additional info == "", make it a dot
			if ($scope.testsToRun[i].additional_info == null) {
				$scope.testsToRun[i].additional_info_show = ".";
			}
		}
	};
	$scope.clearTestRun = function() {
		$scope.testsToRun = [];
		$scope.$parent.testsToRun = [];
	};
});

$(document).on('click', '[data-toggle="lightbox"]', function(event) {
    event.preventDefault();
    $(this).ekkoLightbox();
});
