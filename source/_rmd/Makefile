KNIT = ../_scripts/knit.sh
POSTS_DIR = ../_posts
MD_FILES := $(patsubst %.Rmd, $(POSTS_DIR)/%.html, $(wildcard *.Rmd))

all: $(MD_FILES)

$(POSTS_DIR)/%.html: %.Rmd
	$(KNIT) $< $@
		$(RM) *.md
		$(RM) *.html
