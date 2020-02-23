use std::io::Write;

fn main() {
	let mut cheddar = cheddar::Cheddar::new().unwrap();
	cheddar.module("c_api").unwrap();
	cheddar.insert_code("local FFI = require(\"ffi\")\n");
	cheddar.insert_code("FFI.cdef [[");

	let mut out_file = std::path::PathBuf::new();
	out_file.push("ffi");
	out_file.push("Diamond.lua");
	if let Some(dir) = out_file.parent() {
		std::fs::create_dir_all(dir).unwrap();
	}

	let mut header = cheddar.compile_code().unwrap();
	header.push_str("]]");

	let bytes_buf = header.into_bytes();
	std::fs::File::create(&out_file)
		.and_then(|mut f| f.write_all(&bytes_buf))
		.unwrap();
}
