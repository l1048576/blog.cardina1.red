'use strict';

function html_escape(str) {
	return str
		.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/'/g, '&apos;')
		.replace(/"/g, '&quot;');
}

// num should be >=0.
function zeropad_2digits(num) {
	return ('0' + num).slice(-2);
}

class ArticleInfo {
	constructor(info) {
		this.path = info['path'];
		this.title = info['title'];
		this.excerpt = info['excerpt'];
		this.created_at = info['created_at'];
		this.updated_at = info['updated_at'];
	}
	// context should have:
	// - section_level: int (1-6)
	// - base_url: String
	createElement(context) {
		let ce = (...args) => document.createElement(...args);
		let ct = arg => document.createTextNode(arg);
		let section = ce('section');
		// Title.
		{
			let title_header = ce(`h${context.section_level}`);
			// Anchor.
			{
				let title_anchor = ce('a');
				title_anchor.setAttribute('href', `${context.base_url}${this.path}`);
				title_anchor.textContent = html_escape(this.title);
				title_header.appendChild(title_anchor);
			}
			section.appendChild(title_header);
		}
		// Metadata.
		{
			let metadata = ce('div');
			metadata.style.fontSize = '80%';
			// created_at
			if(this.created_at) {
				let date_block = ce('p');
				// Icon.
				{
					let icon = ce('i');
					icon.classList.add('fa');
					icon.classList.add('fa-calendar-plus-o');
					date_block.appendChild(icon);
				}
				date_block.appendChild(ct(' created:'));
				date_block.appendChild(createDatetimeElement(base_url, this.created_at));
				metadata.appendChild(date_block);
			}
			// updated_at
			if(this.updated_at) {
				let date_block = ce('p');
				// Icon.
				{
					let icon = ce('i');
					icon.classList.add('fa');
					icon.classList.add('fa-calendar-check-o');
					date_block.appendChild(icon);
				}
				date_block.appendChild(ct(' updated:'));
				date_block.appendChild(createDatetimeElement(base_url, this.updated_at));
				metadata.appendChild(date_block);
			}
			section.appendChild(metadata);
		}
		// Summary.
		{
			let summary = ce('p');
			summary.textContent = html_escape(this.excerpt);
			section.appendChild(summary);
		}
		return section;
	}
}

function createDatetimeElement(base_url, dt_iso8601) {
	let ce = (...args) => document.createElement(...args);
	let ct = arg => document.createTextNode(arg);
	const dt = new Date(dt_iso8601);
	const tz_offset = dt.getTimezoneOffset();
	const year4 = dt.getFullYear();
	const month2 = zeropad_2digits(dt.getMonth() + 1);
	let time_elem = ce('time');
	time_elem.setAttribute('datetime', dt_iso8601);
	// Year.
	{
		let year_elem = ce('a');
		year_elem.setAttribute('href', `${base_url}/${year4}/index.html`);
		year_elem.textContent = year4;
		time_elem.appendChild(year_elem);
	}
	time_elem.appendChild(ct('/'));
	// Month.
	{
		let month_elem = ce('a');
		month_elem.setAttribute('href', `${base_url}/${year4}/${month2}/index.html`);
		month_elem.textContent = month2;
		time_elem.appendChild(month_elem);
	}
	{
		const day2 = zeropad_2digits(dt.getDate());
		const weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][dt.getDay()];
		const hour2 = zeropad_2digits(dt.getHours());
		const minute2 = zeropad_2digits(dt.getMinutes());
		time_elem.appendChild(ct(`/${day2} (${weekday}) ${hour2}:${minute2}`));
	}
	// Timezone.
	if(tz_offset == 0) {
		// UTC.
		time_elem.appendChild(ct('Z'));
	} else {
		const tz_hour2 = zeropad_2digits(Math.floor(Math.abs(tz_offset) / 60));
		const tz_minute2 = zeropad_2digits(Math.abs(tz_offset) % 60);
		// Date in JavaScript is weird!
		// -540 for "+0900" timezone.
		time_elem.appendChild(ct(`${(tz_offset>0) ? '-' : '+'}${tz_hour2}:${tz_minute2}`));
	}
	return time_elem;
}
