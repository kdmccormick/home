// utility mongo queries for relating objects in modulestore.

function findDefinitionIdsForBlockQuery(blockQuery) {
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
		},2
		{"_id": 1}
	).map(
		function(obj) {return obj["_id"]}
	);
}

function courseObjectToCourseKey(activeVersion) {
	return (
		"course-v1:" + activeVersion["org"] + 
		"+" + activeVersion["course"] + 
		"+" + activeVersion["run"]
	);
}

function findCourseIdsForStructureIds(structureIds, includeDrafts) {
	var published = db.modulestore.active_versions.find(
		{
			"versions.published-branch": {$in: structureIds}
		},
		{"org": 1, "course": 1, "run": 1}
	).map(
		function(obj) {return courseObjectToCourseKey(obj) }
	);
	var drafts = [];
	if (includeDrafts) {
		drafts = db.modulestore.active_versions.find(
			{
				"versions.draft-branch": {$in: structureIds}
			},
			{"org": 1, "course": 1, "run": 1}
		).map(
			function(obj) {return courseObjectToCourseKey(obj)}
		);
	}
	return Array.concat(published, drafts)
}

function findCourseIdsForBlockQuery(blockQuery) {
	var definitionIds = findDefinitionIdsForBlockQuery(blockQuery);
	var structureIds = findStructureIdsForDefinitionIds(definitionIds);
	var courseIds = findCourseIdsForStructureIds(structureIds)
	return courseIds;
}

// alias to friendler name
var findCoursesForBlock = findCourseIdsForBlockQuery;


function findCourseBlocksByType(org, course, run, blockType) {
	var structureId = db.modulestore.active_versions.findOne(
		{org: org, course: course, run: run}
	).versions["published-branch"];
	var blocks = db.modulestore.structures.findOne(
		{_id: structureId}
	).blocks;
	return blocks.filter(function(b) { return b.block_type == blockType });
}


function findCourseBlockById(org, course, run, blockId) {
	var structureId = db.modulestore.active_versions.findOne(
		{org: org, course: course, run: run}
	).versions["published-branch"];
	var blocks = db.modulestore.structures.findOne(
		{_id: structureId}
	).blocks;
	return blocks.find(function(b) b.block_id == blockId);
}


function descendCourseBlockById(org, course, run, blockId, depth) {
	var block = findCourseBlockById(org, course, run, blockId);
	if (depth <= 0) {
		return block;
	}
	return descendCourseBlockById(org, course, run, block.fields.children[0][1], depth - 1);
}

function getBlockDefinition(block) {
	return db.modulestore.definitions.findOne({_id: block.definition});
}


function findRuns(org, course) {
	return db.modulestore.active_versions.find(
		{org: org, course: course},
		{"run": 1}
	);
}
