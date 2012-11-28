build:
	@echo "Compiling LESS..."
	@lessc --compress less/bootstrap.less > public/css/style.css
	@lessc --compress less/responsive.less > public/css/mobile.css
	@echo "Compiling Coffeescript..."
	@coffee -cj public/js/client.js client.coffee
	@coffee -cj server.js server.coffee
	@echo "Compiling Handlebars templates..."
	@handlebars templates/menu-content.handlebars templates/tab-content.handlebars templates/nav-content.handlebars -f public/js/templates.js
	@echo "Packaging things up..."
	@cat public/js/vendor/jquery.js public/js/vendor/bootstrap.js public/js/vendor/handlebars.js public/js/templates.js public/js/client.js > public/js/application.js
	@rm public/js/templates.js public/js/client.js
	@cp index.html public/index.html
	@echo "Done!"

debug:
	@echo "Compiling LESS..."
	@lessc --compress less/bootstrap.less > public/css/style.css
	@lessc --compress less/responsive.less > public/css/mobile.css
	@echo "Compiling Coffeescript..."
	@coffee -cj public/js/client.js client.coffee
	@coffee -cj server.js server.coffee
	@echo "Compiling Handlebars templates..."
	@handlebars templates/menu-content.handlebars templates/tab-content.handlebars templates/nav-content.handlebars -f public/js/templates.js
	@echo "Packaging things up..."
	@cat public/js/vendor/jquery.js public/js/vendor/bootstrap.js public/js/vendor/handlebars.js public/js/templates.js public/js/client.js > public/js/application.js
	@cp index.html public/index.html
	@echo "Done!"

clean:
	@rm public/js/application.js server.js