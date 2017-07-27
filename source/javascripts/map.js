(function (){
	var mapEl = document.getElementById("map")
	if (!mapEl) return;

	// change default marker icon
  delete L.Icon.Default.prototype._getIconUrl;
  L.Icon.Default.mergeOptions({
    iconUrl: '/images/marker-icon.png',
    iconRetinaUrl: '/images/marker-icon-2x.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.0.3/dist/images/marker-shadow.png'
  });

	var map = L.map(mapEl, {attributionControl: false});//.setView([51.505, -0.09], 13);
	L.control.attribution({position: 'bottomleft'}).addTo(map);

	L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
		maxZoom: 12,
		attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
	}).addTo(map);


	var city_markers = {};
	$.each(MAP_DATA.cities, function (){
		if(this.projects.length <= 0) return;
		var marker = L.marker(this.latlng,{city:this});
		var popup = "<h5>" + this.title + "</h5>" + this.location + "<br>";
		$.each(this.projects, function (){
			var p = MAP_DATA.projects[this];
			popup = popup + '<a data-project="'+p.name+'" href="'+p.url+'">' + p.title + "</a><br>";
		});
		marker.bindPopup(popup);
		marker.bindTooltip(this.title);
		marker.on('popupopen', onCityMarkerPopupToggle);
    	marker.on('popupclose', onCityMarkerPopupToggle);
		city_markers[this.name] = marker;
	});
	var city_markers_group = L.markerClusterGroup({});
	$.each(city_markers, function (){ city_markers_group.addLayer(this); })
	city_markers_group.addTo(map);
	map.fitBounds(city_markers_group.getBounds());

	var NavControl = L.Control.extend({
		options: {
	    position: 'topright'
	  },
	  onAdd: function (map) {
	  	var navcontrol = this;
	  	var containerEl = $($("#navcontrol-template").html());
	  	this._container = containerEl.get(0);
	  	L.DomEvent.disableClickPropagation(this._container);
	  	L.DomEvent.disableScrollPropagation(this._container);
	  	$('> .btn', containerEl).click(function(){
	  		containerEl.toggleClass('open');
	  	});
	  	$('> .cities.pane .city[data-city]', containerEl).click(function(){
	  		var marker = city_markers[$(this).attr('data-city')];
	  		city_markers_group.zoomToShowLayer(marker, function (){
	  			marker.openPopup();
	  		});
	  	});
	  	$('> .city.pane .back', containerEl).click(function(){
	  		map.closePopup();
	  	});
	  	$('> .project.pane .back', containerEl).click(function(){
	  		navcontrol._container.setAttribute('data-pane', 'city');
	  	});
	    return this._container;
	  },
	  onCities: function () {
	  	this._container.setAttribute('data-pane', 'cities');
	  },
	  onCity: function (city) {
	  	var $navcontrol = $(this._container);
	  	var $citypane = $(".city.pane", $navcontrol);
	  	var $projects = $(".projects", $citypane);
	  	$(".title", $citypane).text(city.title);
	 		$(".location", $citypane).text(city.location);
	 		$projects.html('');
	 		$.each(city.projects, function (){
	 			var p = MAP_DATA.projects[this];
	 			$projects.append($('<div data-project="'+this+'" class="project"><div class="title">'+p.title+'</div><div class="summary">'+(p.summary || '')+'</div></div>'));
	 		});
	 		$('.project[data-project]', $projects).click(function(){
	 			$('a[data-project="'+$(this).attr('data-project')+'"]', mapEl).trigger('click');
	 		});
	 		$navcontrol.attr('data-pane', 'city');
	 		return this;
	  },
	  onProject: function (project) {
	  	this._container.setAttribute('data-pane', 'project');
	  	var projectpane = this._container.querySelector('.project.pane');
	  	console.log(projectpane.querySelector('.title'));
	  	projectpane.querySelector('.title').textContent = project.title;
	  	projectpane.querySelector('.summary').textContent = project.summary;
	  	projectpane.querySelector('.logo').setAttribute('src', project.logo);
	  	projectpane.querySelector('.link').setAttribute('href', project.url);
	  	projectpane.querySelector('.about').textContent = project.about;
	  	return this;
	  },
	  open: function () {
	  	this._container.classList.add('open');
	  	return this;
	  }
	});
	var navcontrol = new NavControl();
	map.addControl(navcontrol);

	// map markers

	function onProjectMarkerPopupClick(e) {
		navcontrol.onProject(MAP_DATA.projects[$(this).attr('data-project')]).open();
		e.preventDefault();
		return false;
	}

	function onCityMarkerPopupToggle(e) {
 		var city = e.target.options.city;
 		if(e.type == "popupopen") {
 		 	navcontrol.onCity(city);
 		 	$('.leaflet-popup a[data-project]', mapEl).click(onProjectMarkerPopupClick);
 		} else if(e.type == "popupclose") {
 		 	navcontrol.onCities();
 		 }
 	}

	// search city
  $(".navcontrol .cities.pane .filter", mapEl).keyup(function(){
    var filter = $(this).val().toLowerCase();
    for (var key in MAP_DATA.cities) {
    	var city = MAP_DATA.cities[key];
    	var cityEl = $("#map .pane .city[data-city='"+key+"']");
    	if (
    		city.title.toLowerCase().includes(filter)
    		|| city.location.toLowerCase().includes(filter)
    		|| key.toLowerCase().includes(filter))
    	{
    		cityEl.show();
      } else {
        cityEl.fadeOut();
      }
	}
  });

	// open navcontrol on medium or large screens when load
	$(document).ready(function (){
		if (Foundation.MediaQuery.atLeast('medium')) {
			navcontrol.open();
		}
	});

})();
