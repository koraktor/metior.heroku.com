var formHandler = function() {
    $('input').each(function() {
        if($(this).val() == this.defaultValue) {
            $(this).addClass('inactive');
        }
    });

    $('input.inactive').live('focus', function() {
        $(this).removeClass('inactive');
        this.value = '';
    });

    $('input').blur(function() {
        if($(this).val().match(/^\s*$/)) {
            $(this).addClass('inactive');
            this.value = this.defaultValue;
        }
    });

    $('#submit').click(function() {
        if($('input.inactive').length == 0) {
            window.location = '/' + $('#user').val() + '/' + $('#project').val();
            return false;
        }
    });
};

var dayChange = function() {
    return d3.values(data).map(function(d) { return d.additions - d.deletions });
}

var dayCommits = function() {
    return d3.values(data).map(function(d) { return d.commits });
}

var dayImpact = function() {
    return d3.values(data).map(function(d) { return d.additions + d.deletions });
}

var quantizeAdditions, quantizeCommits, quantizeDeletions, quantizeImpact;

var generateCalendar = function(firstYear, lastYear) {
    var w = 850,
    pw = 14,
    z = ~~((w - pw * 2) / 53),
    ph = z >> 1,
    h = z * 7;

    var calendar = {
        format: d3.time.format("%m/%d/%Y"),
        dates: function(year) {
            var dates = [],
                date = new Date(year, 0, 1),
                week = 0,
                day;
            do {
                dates.push({
                    day: day = date.getDay(),
                    week: week,
                    month: date.getMonth(),
                    Date: calendar.format(date)
                });
                date.setDate(date.getDate() + 1);
                if (day === 6) week++;
            } while (date.getFullYear() === year);
            return dates;
        },
        months: function(year) {
            var months = [],
                date = new Date(year, 0, 1),
                month, firstDay, firstWeek, day, week = 0;
            do {
                firstDay = date.getDay();
                firstWeek = week;
                month = date.getMonth();
                do {
                    day = date.getDay();
                    if (day === 6) week++;
                    date.setDate(date.getDate() + 1);
                } while (date.getMonth() === month);
                months.push({
                    firstDay: firstDay,
                    firstWeek: firstWeek,
                    lastDay: day,
                    lastWeek: day === 6 ? week - 1 : week
                });
            } while (date.getFullYear() === year);
            return months;
        }
    };

    var vis = d3.select("#calendar")
      .selectAll("svg")
        .data(d3.range(firstYear, lastYear + 1))
      .enter().append("svg:svg")
        .attr("width", w)
        .attr("height", h + ph * 2)
      .append("svg:g")
        .attr("transform", "translate(" + pw + "," + ph + ")");

    vis.append("svg:text")
        .attr("transform", "translate(-6," + h / 2 + ")rotate(-90)")
        .attr("text-anchor", "middle")
        .text(function(d) { return d; });

    vis.selectAll("rect.day")
         .data(calendar.dates)
       .enter().append("svg:rect")
         .attr("x", function(d) { return d.week * z; })
         .attr("y", function(d) { return d.day * z; })
         .attr("class", "day")
         .attr("width", z)
         .attr("height", z);

    vis.selectAll("path.month")
        .data(calendar.months)
      .enter().append("svg:path")
        .attr("class", "month")
        .attr("d", function(d) {
          return "M" + (d.firstWeek + 1) * z + "," + d.firstDay * z
              + "H" + d.firstWeek * z
              + "V" + 7 * z
              + "H" + d.lastWeek * z
              + "V" + (d.lastDay + 1) * z
              + "H" + (d.lastWeek + 1) * z
              + "V" + 0
              + "H" + (d.firstWeek + 1) * z
              + "Z";
        });

    vis.selectAll("rect.day").append("svg:title")
        .text(function(d) {
            var additions, commits, deletions;
            var dayData = data[d.Date];
            if(dayData == undefined) {
                additions = 0;
                commits   = 0;
                deletions = 0;
            } else {
                additions = dayData.additions;
                commits   = dayData.commits;
                deletions = dayData.deletions;
            }

            return d.Date + ': ' + commits + ' commits, +' +
                   additions + '/-' + deletions + ' lines';
        });

    dayChange = d3.values(data).map(function(d) { return d.additions - d.deletions });
    dayCommits = d3.values(data).map(function(d) { return d.commits });
    dayImpact = d3.values(data).map(function(d) { return d.additions + d.deletions });

    quantizeAdditions = d3.scale.quantize()
        .domain([0, d3.max(dayChange)])
        .range(d3.range(8));

    quantizeCommits = d3.scale.quantize()
        .domain([0, d3.max(dayCommits)])
        .range(d3.range(8));

    quantizeDeletions = d3.scale.quantize()
        .domain([0, d3.min(dayChange)])
        .range(d3.range(8));

    quantizeImpact = d3.scale.quantize()
        .domain([0, d3.max(dayImpact)])
        .range(d3.range(8));

    return vis;
}

function showChange() {
    $('#change-description').show();
    $('#commits-description').hide();
    $('#impact-description').hide();
    d3.select("#show-change").attr('class', 'active');
    d3.select("#show-commits").attr('class', '');
    d3.select("#show-impact").attr('class', '');
    vis.selectAll("rect.day")
        .attr("class", function(d) {
            var dayData = data[d.Date];
            if(dayData == undefined) {
                return 'day';
            }
            var lines = dayData.additions - dayData.deletions;
            if(lines == 0) {
                return 'day nothing';
            }
            if(lines < 0) {
                return 'day del-' + quantizeDeletions(lines);
            }
            return 'day add-' + quantizeAdditions(lines);
        });
}

function showCommits() {
    $('#change-description').hide();
    $('#commits-description').show();
    $('#impact-description').hide();
    d3.select("#show-change").attr('class', '');
    d3.select("#show-commits").attr('class', 'active');
    d3.select("#show-impact").attr('class', '');
    vis.selectAll("rect.day")
        .attr("class", function(d) {
            var dayData = data[d.Date];
            if(dayData == undefined) {
                return 'day';
            }
            var commits = dayData.commits;
            if(commits == 0) {
                return 'day nothing';
            }
            return 'day add-' + quantizeCommits(commits);
        });
}

function showImpact() {
    $('#change-description').hide();
    $('#commits-description').hide();
    $('#impact-description').show();
    d3.select("#show-change").attr('class', '');
    d3.select("#show-commits").attr('class', '');
    d3.select("#show-impact").attr('class', 'active');
    vis.selectAll("rect.day")
        .attr("class", function(d) {
            var dayData = data[d.Date];
            if(dayData == undefined) {
                return 'day';
            }
            var impact = dayData.additions + dayData.deletions;
            if(impact == 0) {
                return 'day nothing';
            }
            return 'day add-' + quantizeImpact(impact);
        });
}
