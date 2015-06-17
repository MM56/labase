class DateUtils
	@parseToString: (date) =>
		if /\d{2}\/\d{2}\/\d{4}/.test date
			dateParts = date.split("/")
			return dateParts[2] + "-" + dateParts[1] + "-" + dateParts[0]
		return date

	@isValid: (dateString) =>
		d = new Date(dateString)
		return Object.prototype.toString.call(d) == "[object Date]" && !isNaN(d.getTime())