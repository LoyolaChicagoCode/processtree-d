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
	char[] buf; // do not read into a string---way too slow!
	string[int] pmap;
	SList!(int)[int] tmap;

	void printTree(int l, int i) {
		writefln("%s%d: %s", replicate(" ", l), i, pmap[i]);
		if (i in tmap)
			foreach (j ; tmap[i]) printTree(l + 1, j);
	}

	stdin.readln(buf);
	auto toProc = procFromLine(buf);

	while (stdin.readln(buf)) {
		auto p = toProc(buf);
		pmap[p.pid] = p.cmd;
		if (! (p.ppid in tmap)) tmap[p.ppid] = SList!(int)();
		tmap[p.ppid].insert(p.pid);
	}

	foreach (i ; tmap[0]) printTree(0, i);

    return 0;
}

proc delegate(char[]) procFromLine(char[] header) {
	auto cols = header.split;
	auto iPid = cols.countUntil("PID");
	auto iPpid = cols.countUntil("PPID");
	auto iCmd = max(countUntil(header, "CMD"), countUntil(header, "COMMAND"));
	assert(iPid >= 0);
	assert(iPpid >= 0);
	assert(iCmd >= max(iPid, iPpid));
	proc f(char[] line) {
		auto words = line[0..iCmd].split;
		return proc(parse!(int)(words[iPid]), parse!(int)(words[iPpid]), to!(string)(line[iCmd..line.length - 1]));
	}
	return &f;
}