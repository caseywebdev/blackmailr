-/*	  	
-= require jquery	  	
-= require jquery_ujs  	
-= require underscore	  	
-= require backbone	  	
-= require backbone_rails_sync	  	
-= require backbone_datalink  	
-= require extrascore  	
-= require_tree .  	
-*/
function remove_fields(link) {
  $(link).previous("input[type=hidden]").value = "1";
  $(link).up(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).up().insert({
    before: content.replace(regexp, new_id)
  });
}