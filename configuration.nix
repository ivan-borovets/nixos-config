# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, modulesPath, pkgs, specialArgs, options, ... }:
	
{
	imports =
	[
		# Home Manager Installation (in my case, probably)
		# (1) sudo nix-channel --remove home-manager
		# (2) sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
		# (3) sudo nix-channel --update
		<home-manager/nixos>
		./hardware-configuration.nix
	];
	system.copySystemConfiguration = true; # Saves a copy of the configuration.nix that built the current generation inside that generation's path, at /run/current-system/configuration.nix

	# Bootloader
	boot.loader.grub = {
		enable = true;
		configurationLimit = 10;
		device = "/dev/nvme0n1";
		useOSProber = true;
	};

	### Flash Drive Support ###
	boot.supportedFilesystems = [ "ntfs" ];

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# Setting Automatic Garbage Collection
	nix = {
		settings.auto-optimise-store = true;
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 14d";
		};
  		# Enable Flakes
  		package = pkgs.nixFlakes;
  		extraOptions = "experimental-features = nix-command flakes";
  	};

	services.xserver = {
		# Enable the X11 windowing system.
		enable = true;
		# Enable the KDE Plasma Desktop Environment.
		displayManager.sddm.enable = true;
		desktopManager.plasma5.enable = true;
		# Configure keymap in X11
		layout = "us";
		xkbVariant = "";
	};

	### Gaming setup ###
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.opengl.enable = true;
	hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

	### Steam ###
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};
	# Steam should be run with --pipewire argument to display GUI

	# Enable sound with pipewire.
	sound.enable = true;
	hardware.pulseaudio.enable = false; # conflicts with pipewire
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	# If you want to use JACK applications, uncomment this
	#jack.enable = true;
	
	# use the example session manager (no others are packaged yet so this is enabled by default,
	# no need to redefine it in your config for now)
	#media-session.enable = true;
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;
	hardware.bluetooth.enable = true; 	# Enable Bluetooth

	# Enable CUPS to print documents.
	services.printing.enable = true;
	
	networking = {
		hostName = "nixos";		# Define your hostname.
#		wireless.enable = true;	# Enables wireless support via wpa_supplicant.
		# Configure network proxy if necessary
#		proxy.default = "http://user:password@proxy:port/";
#		proxy.noProxy = "127.0.0.1,localhost,internal.domain";
		# Enable networking
		networkmanager.enable = true;
	};  

	# Set your time zone.
	time.timeZone = "Asia/Tashkent";

	# Select internationalisation properties.
	i18n = {
		defaultLocale = "en_US.UTF-8";
		extraLocaleSettings = {
			LC_ADDRESS = "en_US.UTF-8";
			LC_IDENTIFICATION = "en_US.UTF-8";
			LC_MEASUREMENT = "en_US.UTF-8";
			LC_MONETARY = "en_US.UTF-8";
			LC_NAME = "en_US.UTF-8";
			LC_NUMERIC = "en_US.UTF-8";
			LC_PAPER = "en_US.UTF-8";
			LC_TELEPHONE = "en_US.UTF-8";
			LC_TIME = "en_US.UTF-8";
		};
	};

  	# Define a user account. Don't forget to set a password with ‘passwd’.
  	users.users.jj = {
  		isNormalUser = true;
  		description = "jj";
  		extraGroups = [ "networkmanager" "wheel" ];
  		packages = with pkgs; [
#  			thunderbird
		];
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs;
	let
		R-with-my-packages = rWrapper.override{
			packages = with rPackages; [
#				tidyverse
			];
		};
	in
	let
		RStudio-with-my-packages = rstudioWrapper.override{
			packages = with rPackages; [
				car							# Companion to Applied Regression
				data_table					# Extension of 'data.frame'
				DHARMa						# Residual Diagnostics for HierARchical Models
				emmeans						# Estimated Marginal Means, aka Least-Squares Means
				ggstatsplot					# 'ggplot2' Based Plots with Statistical Details
				latex2exp					# Use LaTeX Expressions in Plots
				lme4						# Linear Mixed-Effects Models using 'Eigen' and S4
				lmerTest					# Tests in Linear Mixed Effects Models
				MASS						# Support Functions and Datasets for Venables and Ripley's MASS
				multcomp					# Simultaneous Inference in General Parametric Models
				pacman						# Package Management Tool
				performance					# Assessment of Regression Models Performance
				report						# Automated Reporting of Results and Statistical Models
				see							# Model Visualisation Toolbox for 'easystats' and 'ggplot2'
				snakecase 					# Convert Strings into any Case
				tidyverse					# R packages for data science
				qqplotr						# Quantile-Quantile Plot Extensions for 'ggplot2'
			];
		};
	in [
		### Command line utilities ###
		cht-sh                              # Everything cheat sheet
		exa                                 # Better ls command
		g810-led							# Linux LED controller for some Logitech G Keyboards
		git                                 # Version control
		gitflow								# Extend git with the Gitflow branching model
		gotop                               # Shows processes, CPU usage etc.
		htop                                # A better 'top' command
		lm_sensors							# Tools for reading hardware sensors # (1) sudo sensors-detect (2) sensors
		micro								# Terminal-based text editor
		ncdu								# Disk usage analyzer with an ncurses interface
		nix-prefetch-github					# Prefetch sources from github
		/*	usage: https://github.com/seppeljordan/nix-prefetch-github */
		neofetch                            # screenfetch, but better
		p7zip                               # 7z zip manager
		speedtest-cli                       # Speed test in terminal
		tk			# git citool (GUI)		# A widget toolkit that provides a library of basic elements for building a GUI in many different programming languages
		tree                                # Print file tree in terminal
		unzip                               # Command to unzip files
		wget                                # Download web files
		xclip								# Tool to access the X clipboard from a console application
		youtube-dl                          # YouTube downloader
		zenith-nvidia						# Sort of like top or htop but with zoom-able charts, network, and disk usage, and NVIDIA GPU usage
		zip                                 # Command to zip files
	
   		### Applications ###
   		anki-bin							# Spaced repetition flashcard program
   		anydesk								# Desktop sharing application, providing remote support and online meetings
   		chromium							# An open source web browser from Google
   		deluge                              # Torrent client
   		filelight                           # View disk usage
   		firefox								# A web browser built from Firefox source tree
   		gimp                                # Image editor
   		gparted                             # Partition manager
   		inkscape                            # Vector artwork
   		keepass								# GUI password manager with strong cryptography
   		libsForQt5.kate						# Advanced text editor (kwrite, kate)
   		libsForQt5.kcalc					# Scientific calculator
   		libreoffice                         # More word processing
   		maestral-gui						# GUI front-end for maestral (an open-source Dropbox client) for Linux
		microsoft-edge						# The web browser from Microsoft
   		obsidian							# A powerful knowledge base that works on top of a local folder of plain text Markdown files
   		peek                                # Easy gif creator
   		pinta                               # Paint.NET for Linux
   		telegram-desktop 					# Telegram Desktop messaging app
   		texlive.combined.scheme-full		# TeX Live environment for scheme-full
   		vlc									# Cross-platform media player and streaming server
   		qalculate-qt						# The ultimate desktop calculator
   		
		### Programming languages ###
		jdk19_headless						# The open-source Java Development Kit
		maven								# Build automation tool (used primarily for Java projects)
		(python311.withPackages(ps: with ps;# A high-level dynamically-typed programming language
			[
			# ANB choiсe
			pip 							# The PyPA recommended tool for installing Python packages.
			setuptools						# Easily download, build, install, upgrade, and uninstall Python packages
			virtualenv						# Virtual Python Environment builder

			# My own choice
			jupyterlab						# Jupyter lab environment notebook server extension
			matplotlib						# Python plotting package
			numpy							# Fundamental package for array computing in Python
			pandas							# Powerful data structures for data analysis, time series, and statistics
			scipy							# Fundamental algorithms for scientific computing in Python
			seaborn							# Statistical data visualization
			]))
#		R									# Free software environment for statistical computing and graphics
		R-with-my-packages					# Free software environment for statistical computing and graphics

		### Programming IDEs ###
		jetbrains.pycharm-community			# PyCharm Community Edition
#		rstudio								# Set of integrated tools for the R language
		RStudio-with-my-packages			# Set of integrated tools for the R language
		texstudio							# TeX and LaTeX editor
	];

	### VirtualBox Settings ###
	virtualisation.virtualbox.host.enable = true;
	# https://www.microsoft.com/en-us/software-download/windows11 #
	
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.05"; # Did you read the comment?

	# Configuring Home Manager & zsh
	environment = {
		shells = with pkgs; [ zsh ];
		variables = {
			EDITOR = "micro";
			SYSTEMD_EDITOR = "micro";
			VISUAL = "micro";
		};
	};
	
	users.users.jj.shell = pkgs.zsh;
	programs.zsh.enable = true;

	fonts.fonts = with pkgs; [
		vistafonts
		meslo-lg
		meslo-lgs-nf
		font-awesome
		nerdfonts
	];

	home-manager.users.jj = { pkgs, ... }: {
		home.stateVersion = "23.05";
/*		home.sessionPath = [
			"$HOME/micromamba/condabin"
			"${pkgs.zplug}/bin"
			"/run/wrappers/bin"
			"$HOME/.nix-profile/bin"
			"/etc/profiles/per-user/user/bin"
			"/nix/var/nix/profiles/default/bin"
			"/run/current-system/sw/bin"
			"$HOME/.npm-global/bin"
		]; */
		programs.git = {
			enable = true;
			userName  = "jj";
			userEmail = "jj@jj.jj";
		};
		programs.zsh = {
			enable = true;
			dotDir = ".config/zsh";
			shellAliases = {
				ls = "exa --icons --git --header --group-directories-first -l";
				nixconfig = "micro /etc/nixos/configuration.nix";
				rebuild = "sudo nixos-rebuild switch";
				steam = "steam --pipewire";
			};
			profileExtra = ''
				setopt interactivecomments
			'';
			initExtra = ''
			## include config generated via "p10k configure" manually; zplug cannot edit home manager's zshrc file.
			[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh
			'';
			zplug = {
				enable = true;
				plugins = [
					{ name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
					{ name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
				];
			};
		}; # programs.zsh
	}; # home-manager.users.jj

	# Systemd Service Unit for Keyboard Startup Behavior
	systemd.services.logitech_keyboard_startup = {
		description = "Logitech Keyboard Startup";
		path = with pkgs; [ bash sudo ];
		wantedBy = [ "multi-user.target" "suspend.target" ]; # "multi-user.target" is started as part of boot
		serviceConfig = {
			Type = "oneshot";
			standardOutput = "journal+console"; # unnecessary
		};
		script = ''
			echo "Trying to set up keyboard"
			/run/current-system/sw/bin/g512-led -fx color keys 4838F3
			echo "Keyboard is set up"
		'';
		after = [ "systemd-suspend.service" ]; # Run after system suspend
    # sudo /run/current-system/sw/bin/g512-led -fx color keys 4838F3
	};

	# Systemd Service Unit for Keepass Passwords Backup Behavior
	systemd.services.keepass_passwords_backup = {
		description = "Keepass Passwords Backup";
		path = with pkgs; [ bash ];
#		wantedBy = [ "multi-user.target" ]; # "multi-user.target" is started as part of boot
		serviceConfig = {
			Type = "oneshot";
			standardOutput = "journal+console"; # unnecessary
			Restart = "on-failure";
			RestartSec = "30s";
		};
    	script = ''
			echo "Trying to make passwords backup"
			cp -u /home/jj/Passwords/Database-PC.kdbx '/run/media/jj/ADATA HD650/Пароли/Database-HDD.kdbx'
			cp -u /home/jj/Passwords/Database-PC.kdbx '/home/jj/Dropbox (Maestral)/Passwords/Database-Dropbox.kdbx'
			echo "Passwords backups are made"
		'';
	};

  	systemd.timers.keepass_passwords_backup = {
	    description = "Triggers Keepass Passwords Backup";
	    wantedBy = [ "timers.target" ];
	    timerConfig = {
#	    	OnCalendar = "*-*-* 21:00:00";
	    	OnCalendar = "*-*-* *:00/6"; # Activates every 6 hours
	    	Persistent = true;
			Unit = "keepass_passwords_backup.service";
	    };
	};

#	# Systemd timer unit to trigger the service
#	systemd.timers.my-script-timer = {
#		description = "My Bash Script Timer";
#		wantedBy = [ "timers.target" ];
#		timerConfig = {
#			OnUnitActiveSec = "1m";
#			OnUnitActiveSec = "5s";
#			Unit = "logitech_keyboard_startup.service";
#	};
#};

}
