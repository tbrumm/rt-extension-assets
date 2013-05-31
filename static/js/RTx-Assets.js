jQuery(function() {
    var showModal = function(html) {
        jQuery("<div class='modal'></div>")
            .append(html).appendTo("body")
            .bind('modal:close', function(ev,modal) { modal.elm.remove(); })
            .modal();
    };

    jQuery("input[data-autocomplete]").each(function(){
        var input = jQuery(this);
        var what  = input.attr("data-autocomplete");
        var wants = input.attr("data-autocomplete-return");

        if (!what || !what.match(/^(Users|Groups)$/))
            return;

        input.autocomplete({
            source: RT.Config.WebPath + "/Helpers/Autocomplete/" + what
                    + (wants ? "?return=" + wants : "")
        });
    });

    var assets = jQuery("#assets-accordion");
    assets.accordion({
        // Open the accordion if there's only one fold, otherwise start with
        // all assets collapsed.
        active:         assets.find("h3").length == 1 ? 0 : false,
        collapsible:    true,
        heightStyle:    'content',
        header: "h3"
    }).find("h3 a.unlink-asset").click(function(ev){
        ev.stopPropagation();
        return true;
    });
    jQuery(".ticket-assets form").submit(function(){
        var input = jQuery("[name*=RefersTo]", this);
        if (input.val())
            input.val("asset:" + input.val());
    });
    jQuery("#page-actions-create-linked-ticket").click(function(ev){
        ev.preventDefault();
        var url = this.href.replace(/\/Asset\/CreateLinkedTicket\.html\?id=/g,
                                    '/Asset/Helpers/CreateLinkedTicket?Asset=');
        jQuery.get(
            url,
            showModal
        );
    });
    jQuery("#assets-create").click(function(ev){
        ev.preventDefault();
        jQuery.get(
            RT.Config.WebHomePath + "/Asset/Helpers/CreateInCatalog",
            showModal
        );
    });
});
