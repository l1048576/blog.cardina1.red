'use strict';

const tags_root_url = `${window.location.protocol}//${window.location.host}/tags`

class TagDataEntry {
	constructor(obj) {
		this.items_exact = new Set(obj.items_exact);
		this.items_descendant = new Set(obj.items_descendant);
	}
}

class TagDataStore {
	constructor() {
		this.tags = new Map();
	}
	get_data(tag) {
		let entry = this.tags.get(tag);
		if(entry !== undefined) {
			// The data is cached.
			return Promise.resolve(entry);
		} else {
			// The data is not cached.
			const url = `${tags_root_url}/${tag}/index.json`;
			entry = getAsync(url).then(JSON.parse).then(obj => new TagDataEntry(obj));
			this.tags.set(tag, entry);
			return entry;
		}
	}
	exact(tag) {
		return this.get_data(tag).then(data => data.items_exact);
	}
	descendant(tag) {
		return this.get_data(tag).then(data => data.items_descendant);
	}
	exact_or_descendant(tag) {
		return this.get_data(tag).then(data => set_union(data.items_exact, data.items_descendant));
	}
}

var tag_data_store = new TagDataStore();

function set_union(...sets) {
	return sets.reduce((result, current, index, array) => {
		current.forEach(elem => result.add(elem));
		return result;
	}, new Set());
}

function set_intersection(...sets) {
	if(sets.length) {
		let [first, ...rest] = sets;
		return rest.reduce((result, current, index, array) => {
			return new Set([...current].filter(elem => result.has(elem)))
		}, new Set(first));
	} else {
		return new Set();
	}
}

function set_difference(...sets) {
	if(sets.length) {
		let [first, ...rest] = sets;
		return rest.reduce((result, current, index, array) => {
			return new Set([...current].filter(elem => !result.has(elem)))
		}, new Set(first));
	} else {
		return new Set();
	}
}

function getAsync(url) {
	return new Promise(function(resolve, reject) {
		let request = new XMLHttpRequest();
		request.open('GET', url);

		request.onload = function() {
			if(request.status == 200) {
				resolve(request.response);
			} else {
				reject(Error(request.statusText));
			}
		};
		request.onerror = function() {
			reject(Error("Network error"));
		};

		request.send();
	});
}

function execute_filter(query_obj) {
	// universal_complement: bool
	const universal_complement = document.getElementById('universal-complement').checked;
	// query_result: Set of paths (of articles).
	return execute_subfilter(query_obj)
		.catch(error => {
			console.log(error);
		});
}

// An array of functions returning a promise of a set.
let filter_ops = {
	exact(...args) {
		return Promise.all(args.map(tag_str => tag_data_store.exact(tag_str)))
			.then(results => set_union(...results));
	},
	descendant(...args) {
		return Promise.all(args.map(tag_str => tag_data_store.descendant(tag_str)))
			.then(results => set_union(...results));
	},
	exact_or_descendant(...args) {
		return Promise.all(args.map(tag_str => tag_data_store.exact_or_descendant(tag_str)))
			.then(results => set_union(...results));
	},
	or(...args) {
		return Promise.all(args.map(execute_subfilter))
			.then(results => set_union(...results));
	},
	and(...args) {
		return Promise.all(args.map(execute_subfilter))
			.then(results => set_intersection(...results));
	},
	xor(...args) {
		if(args.length < 2) {
			throw Error('"xor" condition requires exactly 2 subqueries');
		} else {
			return Promise.all(args.slice(0, 2))
				.then(([a, b]) => set_difference(set_union(a, b), set_intersection(a, b)));
		}
	},
	difference(...args) {
		return Promise.all(args.map(execute_subfilter))
			.then(results => set_difference(...results));
	},
};

// Returns promise of a set.
function execute_subfilter(query_obj) {
	const [op, ...args] = query_obj;
	return filter_ops[op](...args);
}
