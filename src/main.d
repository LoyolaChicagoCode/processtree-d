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
	SList!(int)[int] tmap;
	 
	void printTree(int l, int i) {
		writefln("%s%d: %s", replicate(" ", l), pmap[i].pid, pmap[i].cmd);
		if (i in tmap)
			foreach (j ; tmap[i]) printTree(l + 1, j);
	}

	stdin.readln(buf);
	auto toProc = procFromLine(buf);

	while (stdin.readln(buf)) { auto p = toProc(buf); pmap[p.pid] = p; }
	foreach (p ; pmap) {
		if (! (p.ppid in tmap)) tmap[p.ppid] = SList!(int)();
		tmap[p.ppid].insert(p.pid);
	}
	foreach (i ; tmap[0]) printTree(0, i);
	
    return 0;
}

proc delegate(string) procFromLine(string header) {
	auto cols = header.split;
	auto iPid = cols.countUntil("PID"); 
	auto iPpid = cols.countUntil("PPID"); 
	auto iCmd = max(countUntil(cols, "CMD"), countUntil(cols, "COMMAND")); 
	assert(iPid >= 0);
	assert(iPpid >= 0);
	assert(iCmd >= max(iPid, iPpid));
	proc f(string line) {
		auto words = line.split;
		return proc(parse!(int)(words[iPid]), parse!(int)(words[iPpid]), words[iCmd..words.length].join);
	}
	return &f;
}