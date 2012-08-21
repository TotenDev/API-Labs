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
        console.log @data
        response = $.ajax(
            type: @method
            url: @url
            cache: false
            data: @data
            headers:
                Authorization: @auth config.user, config.password
        ).always((data, status) ->
            self.receive response, data, status
        )

    receive: (response, data, status) ->
        @element.find('.results').show()
        @element.find('.response-code').text "#{response.status} (#{response.statusText})"

        data = data.responseText if status isnt "success"

        @element.find('.response-body').text(JSON.stringify(data, null, 4))
        @element.find('.response-headers').text(response.getAllResponseHeaders())

    auth: (user, password) ->
        hash = btoa "#{user}:#{password}"
        "Basic #{hash}"

    getParameters: ->
        self = this
        @data = {}
        @parameters.each (index) ->
            name = $(this).attr('id')
            value = $(this).val()

            if not name then return

            if name is 'id' and self.url.match('{id}')
                self.url = self.url.replace "{id}", value
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

    $(".try-button").live "click", ->
        element = $(this).parent()
        method = $(this).parent().find(".requestMethod").val()
        params = $(this).parent().find(".table .requestParam")
        route = $(this).parent().find(".requestRoute").val()

        new Request config.baseUrl + route, method, params, element
