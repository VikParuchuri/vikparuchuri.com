KNIT = ../_scripts/knit.sh
POSTS_DIR = ../_posts
MD_FILES := $(patsubst %.Rmd, $(POSTS_DIR)/%.markdown, $(wildcard *.Rmd))

all: $(MD_FILES)

$(POSTS_DIR)/%.markdown: %.Rmd
	$(KNIT) $< $@
		$(RM) *.md
		$(RM) *.html
