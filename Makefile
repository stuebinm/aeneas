ifeq (3.81,$(MAKE_VERSION))
  $(error You seem to be using the OSX antiquated Make version. Hint: brew \
    install make, then invoke gmake instead of make)
endif

.PHONY: default
default: build

.PHONY: all
all: build-test-verify nix

####################################
# Variables customizable by the user
####################################

# Set this variable to any value to call Charon to regenerate the .llbc source
# files before running the tests
REGEN_LLBC ?=

# The path to Charon
CHARON_HOME ?= ../charon

# The paths to the test directories in Charon (Aeneas will look for the .llbc
# files in there).
CHARON_TESTS_REGULAR_DIR ?= $(CHARON_HOME)/tests
CHARON_TESTS_POLONIUS_DIR ?= $(CHARON_HOME)/tests-polonius

# The path to the Aeneas executable to run the tests - we need the ability to
# change this path for the Nix package.
AENEAS_EXE ?= bin/aeneas.exe

# The user can specify additional translation options for Aeneas.
# By default we do:
# - unfold all the monadic let bindings to matches (required by F*)
# - insert calls to the normalizer in the translated code to test the
#   generated unit functions
OPTIONS += -unfold-monads -test-trans-units

#
# The rules use (and update) the following variables
#
# The Charon test directory where to look for the .llbc files
CHARON_TEST_DIR =
# The options with which to call Charon
CHARON_OPTIONS =
# The directory in which to extract the result of the translation
SUBDIR :=

####################################
# The rules
####################################

# Build the project, test it and verify the generated files
.PHONY: build-test-verify
build-tests-verify: build tests verify

# Build the project
.PHONY: build
build: build-driver build-lib build-bin-dir doc

.PHONY: build-driver
build-driver:
	cd compiler && dune build $(AENEAS_DRIVER)

.PHONY: build-lib
build-lib:
	cd compiler && dune build aeneas.cmxs

.PHONY: build-bin-dir
build-bin-dir: build-driver build-lib
	mkdir -p bin
	cp -f compiler/_build/default/driver.exe bin/aeneas.exe
	cp -f compiler/_build/default/driver.exe bin/aeneas.cmxs
	cp -rf backends bin

.PHONY: doc
doc:
	cd compiler && dune build @doc

.PHONY: clean
clean:
	cd compiler && dune clean

# Test the project by translating test files to F*
.PHONY: tests
tests: trans-no_nested_borrows trans-paper \
	trans-hashmap trans-hashmap_main \
	trans-external trans-constants \
	trans-polonius-polonius_list trans-polonius-betree_main \
	test-trans-polonius-betree_main

# Verify the F* files generated by the translation
.PHONY: verify
verify:
	cd tests && $(MAKE) all

# Reformat the project
.PHONY: format
format:
	cd compiler && dune promote

# The commands to run Charon to generate the .llbc files
ifeq (, $(REGEN_LLBC))
else
CHARON_CMD = cd $(CHARON_TEST_DIR) && NOT_ALL_TESTS=1 $(MAKE) test-$*
endif

# The command to run Aeneas on the proper llbc file
AENEAS_CMD = $(AENEAS_EXE) $(CHARON_TEST_DIR)/llbc/$(FILE).llbc -dest tests/$(SUBDIR) $(OPTIONS)


# Add specific options to some tests
trans-no_nested_borrows trans-paper: \
	OPTIONS += -test-units -test-trans-units -no-split-files -no-state -no-decreases-clauses
trans-no_nested_borrows trans-paper: SUBDIR:=misc

trans-hashmap: OPTIONS += -template-clauses -no-state
trans-hashmap: SUBDIR:=hashmap

trans-hashmap_main: OPTIONS += -template-clauses
trans-hashmap_main: SUBDIR:=hashmap_on_disk

trans-polonius-polonius_list: OPTIONS += -test-units -test-trans-units -no-split-files -no-state -no-decreases-clauses
trans-polonius-polonius_list: SUBDIR:=misc

trans-constants: OPTIONS += -test-units -test-trans-units -no-split-files -no-state -no-decreases-clauses
trans-constants: SUBDIR:=misc

trans-external: OPTIONS +=
trans-external: SUBDIR:=misc

BETREE_OPTIONS = -template-clauses
trans-polonius-betree_main: OPTIONS += $(BETREE_OPTIONS) -backward-no-state-update
trans-polonius-betree_main: SUBDIR:=betree

# Additional test on the betree: translate it without `-backward-no-state-update`.
# This generates very ugly code, but is good to test the translation.
test-trans-polonius-betree_main: trans-polonius-betree_main
test-trans-polonius-betree_main: OPTIONS += $(BETREE_OPTIONS)
test-trans-polonius-betree_main: SUBDIR:=betree_back_stateful
test-trans-polonius-betree_main: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
test-trans-polonius-betree_main: FILE = betree_main
test-trans-polonius-betree_main:
	$(AENEAS_CMD)

# Generic rules to extract the LLBC from a rust file
# We use the rules in Charon's Makefile to generate the .llbc files: the options
# vary with the test files.
.PHONY: gen-llbc-polonius-%
gen-llbc-polonius-%: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
gen-llbc-polonius-%:
	$(CHARON_CMD)

.PHONY: gen-llbc-%
gen-llbc-%: CHARON_TEST_DIR = $(CHARON_TESTS_REGULAR_DIR)
gen-llbc-%:
	$(CHARON_CMD)

# Generic rule to test the translation of an LLBC file.
# Note that the files requiring the Polonius borrow-checker are generated
# in the tests-polonius subdirectory.
.PHONY: trans-%
trans-%:
trans-polonius-%: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
trans-%: CHARON_TEST_DIR = $(CHARON_TESTS_REGULAR_DIR)

trans-polonius-%: FILE = $*
trans-polonius-%: gen-llbc-polonius-%
	$(AENEAS_CMD)

trans-%: FILE = $*
trans-%: gen-llbc-%
	$(AENEAS_CMD)

# Nix
.PHONY: nix
nix:
	nix build .#checks.x86_64-linux.aeneas-tests --show-trace -L
