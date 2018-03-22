extern crate libc;
#[macro_use]
extern crate serde_json;

use std::ffi::CString;
use libc::c_char;

#[no_mangle]
pub extern "C" fn sayHello(callback: extern "C" fn(*const c_char)) {
    println!("building message...");

    let message = json!({
        "name": "Jack",
        "face": "Awesome",
        "age": 25,
        "cool": true
    });

    let ret = prepare_json(message);

    println!("saying hello...");

    for _n in 1..1001 {
        callback(ret);
    }

    println!("said hello");
}

fn prepare_json(target: serde_json::Value) -> *const c_char {
    return CString::new(target.to_string().as_bytes())
        .unwrap()
        .into_raw();
}
