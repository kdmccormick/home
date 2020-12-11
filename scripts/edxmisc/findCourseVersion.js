var ORG = "...";
var COURSE = "...";
var RUN = "...";

function getLatestCourseStructure(org, course, run) {
	var courseIndex = db.modulestore.active_versions.findOne({
		org: org, course: course, run: run
	});
	return db.modulestore.structures.findOne({
		_id: courseIndex.versions["draft-branch"]
	});
}

function structureToCourseTitle(structure) {
	var rootCourseBlock = structure.blocks.find(function(block) {
		return (
			block.block_type === structure.root[0] &&
			block.block_id === structure.root[1]
		)
	});
	return rootCourseBlock.fields.display_name;
}

function examineStructure(structure) {
	return (
		"  version_guid = " + structure._id + "\n" +
		"  title        = " + structureToCourseTitle(structure) + "\n" +
		"  edited_on	= " + structure.edited_on
	);
}

function lookBackNVersions(structure, numVersionsBack) {
	for (var i = 0; i < numVersionsBack; i++) {
		structure = db.modulestore.structures.findOne({
			_id: structure.previous_version
		})
		if (!structure) return null;
	}
	return structure;
}

function examineAllAvailableVersions(structure) {
	var output = "";
	output += "Current version:\n";
	output += examineStructure(structure) + "\n";

	for (var i = 1; ; i++) {
		var olderStructure = lookBackNVersions(structure, i);
		if (!olderStructure) break;

		output += "\n";
		output += i + " version(s) back:\n";
		output += examineStructure(olderStructure) + "\n";
	}

	output += "\n";
	output += "Showing all available (non-pruned) versions."
	return output;
}

var latestCourseStructure = getLatestCourseStructure(ORG, COURSE, RUN);
examineAllAvailableVersions(latestCourseStructure);

