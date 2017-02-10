function fetchJSONFile(path, callback) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        if (httpRequest.readyState === 4) {
            if (httpRequest.status === 200) {
                var data = JSON.parse(httpRequest.responseText);
                if (callback) callback(data);
            }
        }
    };
    httpRequest.open('GET', path);
    httpRequest.send(); 
}


fetchJSONFile('status.json', function(data) {
    
    var rootNode = document.getElementById('statusList')
   
    var jsonData = [];
    data.map(function(item){
    	jsonData.push([item.serverName,item.serverStatus]);    	
    })
	
    jsonData.map(function(jsonItem){
    	let newchild = document.createElement("div")
		if(jsonItem[1] === "Online") {
			newchild.innerHTML = "<div class='list-group-item'><h4 class='list-group-item-heading'>"+jsonItem[0]+"</h4><p class='list-group-item-text'><i class='fa fa-thumbs-o-up fa-lg' style='color:green'></i> <span class='label label-success'>"+jsonItem[1]+"</span></p></div>"
		} else {
			newchild.innerHTML = "<div class='list-group-item'><h4 class='list-group-item-heading'>"+jsonItem[0]+"</h4><p class='list-group-item-text'><i class='fa fa-exclamation-triangle fa-lg' style='color:red'></i>  <span class='label label-danger'>"+jsonItem[1]+"</span></p></div>"
		}
    	rootNode.appendChild( newchild)
    })
    
});

fetchJSONFile('paneltext.json', function(data) {
    
    var rootNode = document.getElementById('panelHeading')
   
    var jsonData = [];
    data.map(function(item){
    	jsonData.push([item.lastCheck,item.panelTitle]);    	
    })
	
    jsonData.map(function(jsonItem){
    	let newchild = document.createElement("div")
    	newchild.innerHTML = "<h3 class='panel-title'>"+jsonItem[1]+"<small class='pull-right'>Last Updated "+jsonItem[0]+"</small>"
    	rootNode.appendChild( newchild)
    })
    
});

