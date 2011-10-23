import std.algorithm, std.array, std.container, std.conv, std.regex, std.string, std.stdio;

struct proc {
	int pid;
	int ppid;
	string cmd;
	this(int pid, int ppid, string cmd) {
		this.pid = pid; this.ppid = ppid; this.cmd = cmd;
	}
}

int main() {
	string buf;
	proc[int] pmap;
	bool[int][int] tmap;
	 
	void printTree(int l, int i) {
		writefln("%s%d: %s", replicate(" ", l), pmap[i].pid, pmap[i].cmd);
		if (i in tmap)
			foreach (j ; tmap[i].keys) printTree(l + 1, j);
	}

	stdin.readln(buf);
	auto toProc = procFromLine(buf);

	while (stdin.readln(buf)) { auto p = toProc(buf); pmap[p.pid] = p; }
	foreach (p ; pmap) tmap[p.ppid][p.pid] = true;
	foreach (i ; tmap[0].keys) printTree(0, i);
	
    return 0;
}

proc delegate(string) procFromLine(string header) {
	auto ms = map!((auto m) { return m.hit(); })(match(header, regex("\\S+")));
	auto ixs = map!((auto h) { return countUntil(ms, h); })(["PID", "PPID", "CMD", "COMMAND"]);
	auto iPid = ixs[0], iPpid = ixs[1], iCmd = ixs[2], iCommand = ixs[3];
	auto iFirst = min(iPid, iPpid), iSecond = max(iPid, iPpid), iThird = max(iCmd, iCommand);
	assert (iPid >= 0);
	assert (iPpid >= 0);
	assert (iThird > iSecond);
	string pattern; 
	pattern.reserve(iThird * 8);
	pattern ~= replicate("\\S+\\s+", iFirst);
	pattern ~= "(\\S+)\\s+";
	pattern ~= replicate("\\S+\\s+", iSecond - iFirst - 1);
	pattern ~= "(\\S+)\\s+";
	pattern ~= replicate("\\S+\\s+", iThird - iSecond - 1);
	pattern ~= "(\\S.*)";
	bool pidFirst = iPid < iPpid;
	auto rx = regex(pattern);
	proc f(string line) {
		auto cs = match(line, rx).captures;
		auto s1 = cs[1], s2 = cs[2];
		auto first = parse!(int)(s1), second = parse!(int)(s2);
		return proc(pidFirst ? first : second, pidFirst ? second : first, cs[3]);
	}
	return &f;
}