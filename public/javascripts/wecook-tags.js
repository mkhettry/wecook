$(document).ready(function(){
    $('.tag_x').click(function(event) {
        var tag = $(this).parent().text();
        var user_recipe_id = $(this).parent().parent().attr('id').replace("tag_user_recipe_","");
        // fix this later. this will break if we ever change routes.
        var url = "/recipes/" +user_recipe_id + "/delete_tag";
        $.ajax({
            type: 'POST',
            url:  url,
            context: $(this).parent(),
            data: 'tag=' + tag,
            dataType: 'json',
            statusCode: {
                200: function(){
                    $(this).remove();
                },
                500: function() {
                    alert("Could do not delete tag!");
                }
            }
        });

    });
});
