/**
 * Created by romankaczorowski on 07.12.2017.
 */

function checkFare(){
  if($('#name').val()!='' && $('#surname').val() != ''){
    $('#survived').attr("disabled", false);
  }else{
    $('#survived').attr("disabled", true);
  }
 }
(function($){
    $(function(){

      $(document).ready(function(){
        checkFare();
      });

      $('#name').on('change', function(){
          checkFare();
      });
      
      $('#surname').on('change', function(){
          checkFare();
      });

    }); // end of document ready
})(jQuery); // end of jQuery name space