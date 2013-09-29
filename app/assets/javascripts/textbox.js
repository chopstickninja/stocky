$(document).ready(function(){
    
  KEYWORDS = ["when", "increases", "decreases", "use", "portfolio", "for", "cash"];
  
  var highlight = function() {
    
    var queryBox = document.getElementById("queryBox");
    
    var queryText = $(queryBox).text();
    var queryArr = queryText.split(" ");

    console.log(queryText);
    console.log(queryArr);
    
    var highlightedQuery = "";
    queryArr.forEach(function(el){
      el = el.trim();
      console.log(el);
      var keywordIndex = KEYWORDS.indexOf(el);
      if (keywordIndex >= 0) {
        highlightedQuery = highlightedQuery + " <span class=" + el + ">" + el + "</span>";
      } else if (isSymbol(el)) {
        highlightedQuery = highlightedQuery + " <span class='symbol'>" + el + "</span>";       
      } else {
        highlightedQuery = highlightedQuery + " " + el;
      };
    });
    
    
    console.log(highlightedQuery);
    // queryBox.innerHTML = highlightedQuery;
    
    $("#highlight").html(highlightedQuery);
    
    // queryBox.innerHTML += " ";
    // debugger
    // $("#queryBox")[0].focus();
    

  };
  
  var isSymbol = function(str) {
    return str.toUpperCase() == str;
  }
  
  
  
  $(queryBox).keyup(function(event){
    if (event.keyCode == 13) {
      var queryStr = $(queryBox).text();
      debugger
      $.ajax({
        url: "",
        type: "GET",
        data: {query: queryStr},
        success: function(response){
          // Write your call back here, also fill out the url
        }
      });
    }  
    else {
      highlight();
      console.log("changed");      
    }
  });
  
  highlight();
  // console.log("ready!");
  
});
