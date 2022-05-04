
function sortedObjKeys(obj) {
	return Object.keys(obj).sort()
}

function getLibraryOrgs(allOrgsObj) {
	if (allOrgsObj === undefined) allOrgsObj = {};
	db.modulestore.active_versions.find(
		{ "versions.library": { $exists: 1 }},
		{ _id: 0, org: 1}
	).forEach(function(activeVersion) {
		allOrgsObj[activeVersion.org.toLowerCase()] = 1;
	});
	return sortedObjKeys(allOrgsObj);
}

function getSplitMongoCourseOrgs(allOrgsObj) {
	if (allOrgsObj === undefined) allOrgsObj = {};
	db.modulestore.active_versions.find(
		{ "versions.published-branch": { $exists: 1 }},
		{ _id: 0, org: 1}
	).forEach(function(activeVersion) {
		allOrgsObj[activeVersion.org.toLowerCase()] = 1;
	});
	return sortedObjKeys(allOrgsObj);
}

function getOldMongoCourseOrgs(allOrgsObj) {
	if (allOrgsObj === undefined) allOrgsObj = {};
	db.modulestore.find(
		{},
		{"_id": 1}
	).forEach(function(oldCourse) {
		var org = oldCourse._id.org;
		if (org) allOrgsObj[org.toLowerCase()] = 1;
	});
	return sortedObjKeys(allOrgsObj);
}

function getAllOrgs() {
	var allOrgsObj = {};
	getLibraryOrgs(allOrgsObj);
	getSplitMongoCourseOrgs(allOrgsObj);
	getOldMongoCourseOrgs(allOrgsObj);
	return sortedObjKeys(allOrgsObj);
}
