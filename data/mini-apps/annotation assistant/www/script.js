$(document).on('shiny:connected', function(event) {
var MyVars = {};   



$(document.body).on('click', '#write', function() {
    var count = $("[id='id'][type='checkbox']:checked").length;
    //if(a.filter(":checked").length ===0){
    if (count <1) {
      alert('Please select annotation label');
    } else {
    
    Shiny.onInputChange("mydata", MyVars)
    $('#dialog').dialog('close')
    alert('Added ' + MyVars['phrase'] + ' to dictionary as ' + MyVars['annotation'] + '!')
    }
});

$(document.body).on('click', '#dialog input:checkbox', function() {
  // in the handler, 'this' refers to the box clicked on
  var $box = $(this);
  MyVars.annotation = $box.attr('value');
  if ($box.is(":checked")) {

    // the name of the box is retrieved using the .attr() method
    // as it is assumed and expected to be immutable
    var group = "input:checkbox[name='" + $box.attr("name") + "']";
    // the checked state of the group/box on the other hand will change
    // and the current value is retrieved using .prop() method
    $(group).prop("checked", false);
    $box.prop("checked", true);
  } else {
    $box.prop("checked", false);
  }

});

var getSelected = function(){
    var t = '';
    if(window.getSelection) {
        t = window.getSelection();
    } else if(document.getSelection) {
        t = document.getSelection();
    } else if(document.selection) {
        t = document.selection.createRange().text;
    }
    return t;
}



$(function(){
    $('#text').bind('mouseup', function(e){
        var selection;
        
        if (window.getSelection) {
          selection = window.getSelection();
        } else if (document.selection) {
          selection = document.selection.createRange();
        }
        
        //selection.toString() !== '' && alert(selection.toString());
		    MyVars.phrase = selection.toString();
		var popUpList = $('<div id ="dialog"><input id ="id" type="checkbox" value="Pathology" name="fooby[1][]">Pathology<br><input id ="id" type="checkbox" value="Anatomical Location" name="fooby[1][]">Anatomical Location<br><input id ="id" type="checkbox" value="Laterality" name="fooby[1][]">Laterality<br><input id ="id" type="checkbox" value="Negation" name="fooby[1][]">Negation<br><input id ="id" type="checkbox" value="Imaging Technique" name="fooby[1][]">Imaging Technique<br><br><button id="write">Add to dictionary</button></div>');
		

		popUpList.dialog({
  title: selection.toString(),
		           autoOpen: true,
        modal: true,
        open: function() {
            jQuery('.ui-widget-overlay').bind('click', function() {
                jQuery('#dialog').dialog('close')
                })
                }
		});
    });
});
})
