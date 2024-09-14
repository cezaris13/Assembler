SHELL:=/bin/bash

tasksDirectory = ./tasks
laboratoryWork = $(shell ls $(tasksDirectory))
yasmexe = 'yasm.exe'
yasmlib = 'yasmlib.asm'
yasmmac = 'yasmmac.inc'
cwsdpmi = 'cwsdpmi.exe'
config = dosbox.conf
configTemplate = dosboxTemplate.conf
UNAME := $(shell uname)
mainFiles = './main_files'
currDir = $(shell pwd)

init:
ifeq ($(UNAME), Darwin)
	brew install --cask dosbox
endif
	@for task in $(laboratoryWork) ; do \
		cp $(mainFiles)/$(yasmexe) $(tasksDirectory)/$$task/$(yasmexe); \
		cp $(mainFiles)/$(yasmmac) $(tasksDirectory)/$$task/$(yasmmac); \
		cp $(mainFiles)/$(yasmlib) $(tasksDirectory)/$$task/$(yasmlib); \
		cp $(mainFiles)/$(cwsdpmi) $(tasksDirectory)/$$task/$(cwsdpmi); \
	done

run:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Variable 'PROJECT' is empty. Run 'make run PROJECT=projectName'"; \
	else \
		if [ ! -d "$(tasksDirectory)/$(PROJECT)" ]; then \
			echo "Directory '$(tasksDirectory)/$(PROJECT)' does not exist."; \
		else \
		 	cp $(configTemplate) $(config);\
			echo 'MOUNT C \"$(currDir)/tasks/$(PROJECT)\"' >> $(config);\
			echo 'C:' >> $(config);\
			open -a DOSBox --args -c $(currDir)/$(config);\
		fi \
	fi
clean:
ifeq ($(UNAME), Darwin)
	brew uninstall --cask dosbox
endif
	rm $(config)
	rm -rf $(tasksDirectory)/**/*.COM
	rm -rf $(tasksDirectory)/**/$(yasmexe)
	rm -rf $(tasksDirectory)/**/$(yasmmac)
	rm -rf $(tasksDirectory)/**/$(yasmlib)
	rm -rf $(tasksDirectory)/**/$(cwsdpmi)
