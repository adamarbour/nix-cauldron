{ config, ... }:
{
	programs.bash = {
		enable = true;
		enableCompletion = true;
		
		historyFile = "${config.xdg.stateHome}/bash/history";
		historySize = 100;
		shellOptions = [
			"cdspell"
			"checkjobs"
			"checkwinsize"
			"dirspell"
			"globstar"
			"histappend"
			"no_empty_cmd_completion"
		];
	};
}
