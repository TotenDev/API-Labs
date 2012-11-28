@config =
    baseUrl: ''
    user: ''
    password: ''

Handlebars.registerHelper "getModuleId", (module) ->
    module.toLowerCase().replace /\s/g, ""

Handlebars.registerHelper "getTabClass", (method) ->
    method = method.toLowerCase()
    method + "-tab"

Handlebars.registerHelper "getLabelClass", (method) ->
    method = method.toLowerCase()
    switch method
        when "get"
            "label-info"
        when "post"
            "label-success"
        when "put"
            "label-warning"
        when "delete"
            "label-important"

class Application
    constructor: (@config) ->
        self = this
        $.getJSON @config, (contents) ->
            $(".docs-menu").html Handlebars.templates["menu-content"](contents)
            self.open(contents.default)
            $("a[id='#{contents.default}']").parent().addClass('active')

    open: (data) ->
        $.getJSON 'data/' + data, (contents) ->
            $(".content").html Handlebars.templates["tab-content"](contents)
            $(".sidebar-nav").html Handlebars.templates["nav-content"](contents)

            config.baseUrl = contents.base

            if contents.user
                config.user = contents.user
                config.password = contents.password

class Request
    constructor: (@url, @method, @parameters, @element) ->
        @getParameters()
        @send()

    send: ->
        self = this
        @element.find('.request-url').text(@url)
        response = $.ajax(
            type: 'POST'
            url: 'http://docs.office.totendev.com:8088/request'
            cache: false
            dataType: JSON
            contentType: "application/json"
            data: JSON.stringify(
                method: @method
                url: @url
                parameters: @data
                auth: "#{config.user}:#{config.password}"
            )
        ).always((data, status) ->
            response = JSON.parse(data.responseText)
            self.element.find('.results').show()
            self.element.find('.response-data').text("Returned status #{response.status} in #{response.time} seconds")
            self.element.find('.response-body').text(response.body)
            self.element.find('.response-headers').text(response.header)
        )

    getParameters: ->
        self = this
        @data = {}
        @parameters.each (index) ->
            name = $(this).attr('id')
            value = $(this).val()

            if not name then return

            if self.url.match("{#{name}}")
                self.url = self.url.replace "{#{name}}", value
                return

            self.data[name] = value

$ ->
    app = new Application 'data/config.json'

    $('.dropdown-toggle').dropdown()

    $("#tabbedModules a").click (e) ->
        e.preventDefault()
        $(this).tab "show"

    $(".tab-header").live "click", ->
        $(this).parent().find(".details").toggle()

    $(".doc-menu-item").live "click", ->
        app.open($(this).attr('id'))
        $('.docs-menu li').each ->
            $(this).removeClass('active')
        $(this).parent().addClass('active')

    $(".try-button").live "click", ->
        element = $(this).parent()
        method = $(this).parent().find(".requestMethod").val()
        params = $(this).parent().find(".table .requestParam")
        route = $(this).parent().find(".requestRoute").val()

        new Request config.baseUrl + route, method, params, element
