$(document).ready(function(){
    
  KEYWORDS = ["when", "increases", "decreases", "use", "portfolio", "for", "cash"];
  
  var highlight = function() {
    var queryBox = document.getElementById("queryBox");
      var queryText = $(queryBox).text();
      var queryArr = queryText.split(" ");

    // 
    // console.log(queryText);
    // console.log(queryArr);
    
    var highlightedQuery = "";
    queryArr.forEach(function(el){
      el = el.trim();
      var keywordIndex = KEYWORDS.indexOf(el);
      if (keywordIndex >= 0) {
        highlightedQuery = highlightedQuery + " <span class=" + el + ">" + el + "</span>";
      } else if (isSymbol(el)) {
        highlightedQuery = highlightedQuery + " <span class='symbol'>" + el + "</span>";       
      } else {
        highlightedQuery = highlightedQuery + " " + el;
      };
    });
    
    $("#highlight").html(highlightedQuery);
  };
  
  var isSymbol = function(str) {
    return str.toUpperCase() == str;
  };
  
  var highlight2 = function() {
    var exitBox = document.getElementById("exitBox");
    
    var exitText = $(exitBox).text();
    var exitArr = exitText.split(" ");

    // console.log(exitText);
//     console.log(exitArr);
    
    var highlightedExit = "";
    exitArr.forEach(function(el){
      el = el.trim();
      var keywordIndex = KEYWORDS.indexOf(el);
      if (keywordIndex >= 0) {
        highlightedExit = highlightedExit + " <span class=" + el + ">" + el + "</span>";
      } else if (isSymbol(el)) {
        highlightedExit = highlightedExit + " <span class='symbol'>" + el + "</span>";       
      } else {
        highlightedExit = highlightedExit + " " + el;
      };
    });
    
    $("#highlightExit").html(highlightedExit);
  };
  
  var isSymbol = function(str) {
    return str.toUpperCase() == str;
  };
  
  

  if (document.getElementById("queryBox")) {
    highlight();
    
    $("#queryBox").keyup(function(event){
      highlight();
    });
    
  };

  if (document.getElementById("exitBox")) {
    highlight2();
    
    $("#exitBox").keyup(function(event){
      highlight2();
    });
    
  };
  // };
  
  // if (document.getElementById("exitBox")) {
  //   $(queryBox).keyup(function(event){
  //     highlight2();
  //   }
  // 
  //   highlight2();
  // };
  
  
});
