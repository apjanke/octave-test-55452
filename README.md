octave-test-55452
=================

Development tests for [GNU Octave bug #55452](https://savannah.gnu.org/bugs/?55452) (character encoding support for fopen and file reading/writing).

This is a temporary repo to hold test code used while testing patches on that bug.

##  Repo layout

* `README.md`
* `encoded-files/`
  * `ex-NNN/` – one example of encoded files
    * `README.md` – description of this one example
    * `ref.txt` – UTF-8 encoded reference value
    * `txt-<encoding>.txt` – same text encoded in specified encoding
    * `txt-<encoding>@<variant>.txt` – same text encoded in specified encoding, with a variation that can't be expressed with encoding name alone (like whether UTF-16 has a BOM or not)
* `samples/` - various samples of text
