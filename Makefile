ifeq (3.81,$(MAKE_VERSION))
  $(error You seem to be using the OSX antiquated Make version. Hint: brew \
    install make, then invoke gmake instead of make)
endif

.PHONY: default
default: build

.PHONY: all
all: build-tests-verify nix

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
OPTIONS +=

#
# The rules use (and update) the following variables
#
# The Charon test directory where to look for the .llbc files
CHARON_TEST_DIR =
# The options with which to call Charon
CHARON_OPTIONS =
# The backend sub-directory in which to generate the files
BACKEND_SUBDIR :=
# The directory in which to extract the result of the translation
SUBDIR :=

####################################
# The rules
####################################

# Build the project, test it and verify the generated files
.PHONY: build-tests-verify
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
	transp-polonius_list transp-betree_main \
	test-transp-betree_main \
	trans-loops \
	trans-array trans-traits # TODO: generalize to all backends

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
AENEAS_CMD = $(AENEAS_EXE) $(CHARON_TEST_DIR)/llbc/$(FILE).llbc -dest tests/$(BACKEND_SUBDIR)/$(SUBDIR) $(OPTIONS)


# Add specific options to some tests
trans-no_nested_borrows trans-paper: \
	OPTIONS += -test-trans-units -no-split-files -no-state
trans-no_nested_borrows trans-paper: SUBDIR := misc
tfstar-no_nested_borrows tfstar-paper:
tlean-no_nested_borrows: SUBDIR :=
tlean-paper: SUBDIR :=
thol4-no_nested_borrows: SUBDIR := misc-no_nested_borrows
thol4-paper: SUBDIR := misc-paper

trans-array: OPTIONS += -no-state
trans-array: SUBDIR := array
tfstar-array: OPTIONS += -decreases-clauses -template-clauses
tcoq-array: OPTIONS += -use-fuel
tlean-array: SUBDIR :=
tlean-array: OPTIONS +=
thol4-array: OPTIONS +=

trans-traits: OPTIONS += -no-state
trans-traits: SUBDIR := traits
tfstar-traits: OPTIONS += -decreases-clauses -template-clauses
tcoq-traits: OPTIONS += -use-fuel
tlean-traits: SUBDIR :=
tlean-traits: OPTIONS +=
thol4-traits: OPTIONS +=

# TODO: activate the arrays for all the backends
thol4-array:
	echo "Ignoring the array test for HOL4"

trans-loops: OPTIONS += -no-state
trans-loops: SUBDIR := misc
tfstar-loops: OPTIONS += -decreases-clauses -template-clauses
tcoq-loops: OPTIONS += -use-fuel -no-split-files
tlean-loops: SUBDIR :=
thol4-loops: SUBDIR := misc-loops

# TODO: reactivate -test-trans-units
trans-hashmap: OPTIONS += -no-state
trans-hashmap: SUBDIR := hashmap
tfstar-hashmap: OPTIONS += -decreases-clauses -template-clauses
tcoq-hashmap: OPTIONS += -use-fuel
tlean-hashmap: SUBDIR :=
tlean-hashmap: OPTIONS += -no-gen-lib-entry # We add a custom import in the Hashmap.lean file: we do not want to overwrite it
thol4-hashmap: OPTIONS +=

# TODO: reactivate -test-trans-units
trans-hashmap_main: OPTIONS +=
trans-hashmap_main: SUBDIR := hashmap_on_disk
tfstar-hashmap_main: OPTIONS += -decreases-clauses -template-clauses
tcoq-hashmap_main: OPTIONS += -use-fuel
tlean-hashmap_main: SUBDIR :=
thol4-hashmap_main: OPTIONS +=

transp-polonius_list: OPTIONS += -test-trans-units -no-split-files -no-state
transp-polonius_list: SUBDIR := misc
tfstarp-polonius_list: OPTIONS +=
tcoqp-polonius_list: OPTIONS +=
tleanp-polonius_list: SUBDIR :=
tleanp-polonius_list: OPTIONS +=
thol4p-polonius_list: SUBDIR := misc-polonius_list
thol4p-polonius_list: OPTIONS +=

trans-constants: OPTIONS += -test-trans-units -no-split-files -no-state
trans-constants: SUBDIR := misc
tfstar-constants: OPTIONS +=
tcoq-constants: OPTIONS +=
tlean-constants: SUBDIR :=
tlean-constants: OPTIONS +=
thol4-constants: SUBDIR := misc-constants
thol4-constants: OPTIONS +=

trans-external: OPTIONS += -test-trans-units
trans-external: SUBDIR := misc
tfstar-external: OPTIONS +=
tcoq-external: OPTIONS +=
tlean-external: SUBDIR :=
tlean-external: OPTIONS +=
thol4-external: SUBDIR := misc-external
thol4-external: OPTIONS +=

BETREE_FSTAR_OPTIONS = -decreases-clauses -template-clauses
transp-betree_main: OPTIONS += -backward-no-state-update -test-trans-units
transp-betree_main: SUBDIR:=betree
tfstarp-betree_main: OPTIONS += $(BETREE_FSTAR_OPTIONS)
tcoqp-betree_main: OPTIONS += -use-fuel
tleanp-betree_main: SUBDIR :=
tleanp-betree_main: OPTIONS +=
thol4-betree_main: OPTIONS +=

# Additional test on the betree: translate it without `-backward-no-state-update`.
# This generates very ugly code, but is good to test the translation.
.PHONY: test-transp-betree_main
test-transp-betree_main: transp-betree_main
test-transp-betree_main: OPTIONS += -backend fstar -test-trans-units
test-transp-betree_main: OPTIONS += $(BETREE_FSTAR_OPTIONS)
test-transp-betree_main: BACKEND_SUBDIR := "fstar"
test-transp-betree_main: SUBDIR:=betree_back_stateful
test-transp-betree_main: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
test-transp-betree_main: FILE = betree_main
test-transp-betree_main:
	$(AENEAS_CMD)

# Generic rules to extract the LLBC from a rust file
# We use the rules in Charon's Makefile to generate the .llbc files: the options
# vary with the test files.
.PHONY: gen-llbc-%
gen-llbc-%: CHARON_TEST_DIR = $(CHARON_TESTS_REGULAR_DIR)
gen-llbc-%:
	$(CHARON_CMD)

# "p" stands for "Polonius"
.PHONY: gen-llbcp-%
gen-llbcp-%: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
gen-llbcp-%:
	$(CHARON_CMD)

# Generic rules to test the translation of an LLBC file.
# Note that the files requiring the Polonius borrow-checker are generated
# in the tests-polonius subdirectory.
.PHONY: trans-%
trans-%: CHARON_TEST_DIR = $(CHARON_TESTS_REGULAR_DIR)
trans-%: FILE = $*
trans-%: gen-llbc-% tfstar-% tcoq-% tlean-% thol4-%
	echo "# Test $* done"

# "p" stands for "Polonius"
.PHONY: transp-%
transp-%: CHARON_TEST_DIR = $(CHARON_TESTS_POLONIUS_DIR)
transp-%: FILE = $*
transp-%: gen-llbcp-% tfstarp-% tcoqp-% tleanp-% thol4p-%
	echo "# Test $* done"

.PHONY: tfstar-%
tfstar-%: OPTIONS += -backend fstar
tfstar-%: BACKEND_SUBDIR := fstar
tfstar-%:
	$(AENEAS_CMD)

# "p" stands for "Polonius"
.PHONY: tfstarp-%
tfstarp-%: OPTIONS += -backend fstar
tfstarp-%: BACKEND_SUBDIR := fstar
tfstarp-%:
	$(AENEAS_CMD)

.PHONY: tcoq-%
tcoq-%: OPTIONS += -backend coq
tcoq-%: BACKEND_SUBDIR := coq
tcoq-%:
	$(AENEAS_CMD)

# "p" stands for "Polonius"
.PHONY: tcoqp-%
tcoqp-%: OPTIONS += -backend coq
tcoqp-%: BACKEND_SUBDIR := coq
tcoqp-%:
	$(AENEAS_CMD)

.PHONY: tlean-%
tlean-%: OPTIONS += -backend lean
tlean-%: BACKEND_SUBDIR := lean
tlean-%:
	$(AENEAS_CMD)

# "p" stands for "Polonius"
.PHONY: tleanp-%

tleanp-%: OPTIONS += -backend lean
tleanp-%: BACKEND_SUBDIR := lean
tleanp-%:
	$(AENEAS_CMD)

.PHONY: thol4-%
thol4-%: OPTIONS += -backend hol4
thol4-%: BACKEND_SUBDIR := hol4
thol4-%:
	$(AENEAS_CMD)

.PHONY: thol4p-%
thol4p-%: OPTIONS += -backend hol4
thol4p-%: BACKEND_SUBDIR := hol4
thol4p-%:
	$(AENEAS_CMD)

# Nix - TODO: add the lean tests
.PHONY: nix
nix: nix-aeneas-tests nix-aeneas-verify-fstar nix-aeneas-verify-coq nix-aeneas-verify-hol4

.PHONY: nix-aeneas-tests
nix-aeneas-tests:
	nix build .#checks.x86_64-linux.aeneas-tests --show-trace -L

.PHONY: nix-aeneas-verify-fstar
nix-aeneas-verify-fstar:
	nix build .#checks.x86_64-linux.aeneas-verify-fstar --show-trace -L

.PHONY: nix-aeneas-verify-coq
nix-aeneas-verify-coq:
	nix build .#checks.x86_64-linux.aeneas-verify-coq --show-trace -L

.PHONY: nix-aeneas-verify-lean
nix-aeneas-verify-lean:
	nix build .#checks.x86_64-linux.aeneas-verify-lean --show-trace -L

.PHONY: nix-aeneas-verify-hol4
nix-aeneas-verify-hol4:
	nix build .#checks.x86_64-linux.aeneas-verify-hol4 --show-trace -L
