# Simple

## Create Tree

~~~sql
SELECT kapi_tree_structure_new_nodes('categories','brands');
SELECT kapi_tree_structure_new_data('categories.brands_nodes','categories','brands');
SELECT kapi_tree_structure_new_tree('categories.brands_nodes', 'categories','brands');

~~~