function aim_print_db(){
  setTimeout(function(){window.print();}, 500);
}

Event.observe(window, 'load', function(){ aim_print_db() });
