Server.default.options.memSize_(2.pow(16));

~dict = Dictionary.new;

Server.default.waitForBoot{
	Window.closeAll;

	~run = {
		var path, html, scenes, view, win;
		path = PathName(thisProcess.nowExecutingPath).parentPath ++ "src/";
		html = File.readAllString(path ++ "UI.html");
		scenes = PathName(path ++ "scenes/").entries.collect{ | file | file.fullPath.load };

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
		var dict = Dictionary.new;
		~view.runJavaScript(
			"(() => {
                       let lines = document.body.innerText.split(/\\s+/);
                          let dict = {};
                          for (let i = 0; i < lines.length - 1; i++) {
                             if (/^Q\\d+$/.test(lines[i])) {
                                dict[lines[i]] = lines[i + 1];
                                i++;
                            }
                    }
                    return JSON.stringify(dict);
            })()",
			{
				| file |
				~dict = file.parseJSON.postln;
			}
		);
	};

	Server.default.sync;

	~run.value;
}