Server.default.options.memSize_(2.pow(16));
Server.default.waitForBoot{
	~run = {
		var path, html, view, win;
		path = PathName(thisProcess.nowExecutingPath).parentPath ++ "src/index.html";
		html = File.readAllString(path);

		~view = WebView.new;
		~view.setHtml(html);

		win = Window("Q-SC", Rect(0, 0, Window.screenBounds.width, Window.screenBounds.height));
		win.layout = VLayout(~view);
		win.front;

		Tdef(\update, {
			loop{

				{
					~view.onJavaScriptMsg = { ~readContent.value };
				}.defer;

				0.1.wait;
			}.defer
		}).play;
	};

	~readContent = {
		"hallo".postln;
		~view.runJavaScript("document.body.innerText", { | content |
			var i = 0;
			content.size.postln;
			content.asString.size.postln;
		});
	};

	Server.default.sync;

	~run.value;
}