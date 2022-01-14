
#
# Given an Object, turns it into a dictionary of 
# simple json path key/value pairs.
# for all scalar values, regardless of depth
#
def flatten_object:
[
    [  
    
      paths(scalars) as $p
      | { ( $p| join(".") ) : getpath($p) }
    ]
    | add 
] 
;

#
# Unique an array of scalar values (strings only) in an array
# but retain their original order (uniq, not sort and uniq)
#
def unique_scalars_unsorted:
   reduce .[] as $x ({}; . + { ($x) : 1 }) | keys_unsorted

;

#
# Given an array of objects, which are flat (keys, with values)
# no nested keys
# return a CSV. The objects can be mishapen
# 
def arr_flat_objects_to_csv: 

  (map(keys_unsorted) | add | unique_scalars_unsorted) as $cols
  | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv
;


#
# Given an array of objects, nested or otherwise simple k/v maps
# turn the entire set into a CSV
#
# [
#     {
#         "array": [ 8, 7 , 6 ],
#         "something": "here",
#         "someproperty": "there",
#         "a": {
#             "b": {
#                 "c": 1234
#             }
#         },
#         "extra-only-here": true
#     },
#     {
#         "something": "here",
#         "someproperty": "there",
#         "array": [ 1, 2, 3, 4],
#         "a": {
#             "b": {
#                 "c": 1234
#             }
#         }
#     }
# ]
#
# to 
#
# "array.0","array.1","array.2","something","someproperty","a.b.c","extra-only-here","array.3"
# 8,7,6,"here","there",1234,true,
# 1,2,3,"here","there",1234,,4

def arr_objects_to_csv:
    map(flatten_object) | flatten | arr_flat_objects_to_csv

;


# Original from Cook Book - https://github.com/stedolan/jq/wiki/Cookbook#convert-a-csv-file-with-headers-to-json
# objectify/1 expects an array of atomic values as inputs, and packages
# these into an object with keys specified by the "headers" array and
# values obtained by trimming string values, replacing empty strings
# by null, and converting strings to numbers if possible.
def objectify(headers):
  def tonumberq: tonumber? // .;
  def trimq: if type == "string" then sub("^ +";"") | sub(" +$";"") else . end;
  def tonullq: if . == "" then null else . end;
  . as $in
  | reduce range(0; headers | length) as $i
      (
      
      {}
      
      ; . + setpath([ headers[$i] | split(".")[] | tonumberq ] ; ($in[$i] | trimq | tonumberq | tonullq) ));

#
# take a CSV row string, and return a stream of values
#
def row_to_array:
  # match("(?:\\s*(?:\"([^\"]*)\"|([^,]+))\\s*,?)+?";"g") | .captures[0].string
  match("(?:^|,)(?=[^\"]|(\")?)\"?((?(1)[^\"]*|[^,\"]*))\"?(?=,|$)"; "g") |
  if  .captures[1].length > 0 then .captures[1].string else null end
;

def csv_to_json:
  # filter out empty rows, and convert each row to an array of values
  # via regex
  split("\n")
  | [ .[] | select(length > 0) | [ row_to_array ] ]
  | .[0] as $headers

  # for each data row
  | reduce (.[1:][] | select(length > 0) ) as $row
      ([]; . + [ $row|objectify($headers) ]);


# an example CSV
# "0","1","2","arr.0","arr.1","arr.2","something","someproperty","a.b.c","extra-only-here","arr.3"
# 1,2,3,,,,,,,,
# ,,,8,7,6,"here","there",1234,true,
# ,,,1,2,3,"here","there",1234,,4

