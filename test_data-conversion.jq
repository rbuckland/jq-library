import "jq-unit" as jqunit;
import "data-conversion" as dc;

#
# Test case: simple nested
#
def simple_nested_input_data: 
  [
    { 
      "asb" : 123,
      "foobar" :222,
      "abc": "asas"
    },
    { 
      "asb" : 2223,
      "foobar" :222,
      "abc": "asas"
    },
    { 
      "someother" : 2223,
      "object" :222
    }
  ]
;
def simple_nested_output_csv: 
  [
    "\"asb\",\"foobar\",\"abc\",\"someother\",\"object\"",
    "123,222,\"asas\",,",
    "2223,222,\"asas\",,",
    ",,,2223,222"
  ];

def simple_nested_is_csv: 
  jqunit::test("simple nested converts to csv") |
  jqunit::Given(simple_nested_input_data)       |
  jqunit::When([ . | dc::arr_flat_objects_to_csv ])  |
  jqunit::Then(.== simple_nested_output_csv)
;

jqunit::allSpecs(
    simple_nested_is_csv
)
