// utility mongo queries for relating objects in modulestore.

function findDefinitionsIdForBlockQuery(blockQuery) {
	return db.modulestore.definitions.find(
		blockQuery,
		{"_id": 1}
	).map(
		function(obj) {return obj["_id"]}
	);
}

function findStructureIdsForDefinitionIds(definitionIds) {
	return db.modulestore.structures.find(
		{
			blocks: {
				$elemMatch: {
					definition: {$in: definitionIds},
				}
			}
		},
		{"_id": 1}
	).map(
		function(obj) {return obj["_id"]}
	);
}

function findCourseIdsForStructureIds(structureIds) {
	return db.modulestore.active_versions.find(
		{
			"versions.published-branch": {$in: structureIds}
		},
		{"org": 1, "course": 1, "run": 1}
	).map(
		function(obj) {return obj}
	);
}

function findCourseIdsForBlockQuery(blockQuery) {
	var definitionIds = findDefinitionsIdsForBlockQuery(blockQuery);
	var structureIds = findStructureIdsForDefinitionIds(definitionIds);
	var courseIds = findCourseIdsForStructureIds(structureIds)
	return courseIds;
}

// alias to friendler name
var findCoursesForBlock = findCourseIdsForBlockQuery;
