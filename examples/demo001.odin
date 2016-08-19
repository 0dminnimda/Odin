#load "basic.odin"
#load "math.odin"
// #load "game.odin"

main :: proc() {
	_ = hellope();
	procedures();
	variables();
	constants();
	types();
	data_control();
	// run_game();
}

hellope :: proc() -> int {
	print_string("Hellope, 世界\n");
	return 1;
}

apple, banana, carrot: bool;
box, carboard: bool = true, false;
hellope_value := hellope();

variables :: proc() {
	i: int; // initialized with zero value
	j: int = 1;
	x, y: int = 1, 2;

	// Type inference
	apple, banana, carrot := true, 123, "carrot";


	// Basic Types of the Language
	//
	// bool
	//
	// i8 i16 i32 i64 i128
	// u8 u16 u32 u64 u128
	//
	// f32 f64
	//
	// int uint (size_of(int) = size_of(rawptr))
	//
	// rawptr
	//
	// string
	//
	// byte - alias for u8
	// rune - alias for i32 // Unicode Codepoint
	//
	// untyped bool      - "untyped" types can implicitly convert to any of the "typed" types
	// untyped integer
	// untyped float
	// untyped pointer
	// untyped string
	// untyped rune


	// // Zero values
	zero_numeric := 0;
	zero_boolean := false;
	zero_pointer := null;
	zero_string1 := ""; // Escaped string
	zero_string2 := ``; // Raw string

	// Unary operators
	// +a
	// -a
	// ~a
	// !a

	// Binary operators
	// a + b
	// a - b
	// a ~ b
	// a | b

	// a * b
	// a / b
	// a % b
	// a & b
	// a &~ b   == a & (~b)
	// a << b
	// a >> b

	// a as Type
	// a transmute Type

	// a == b
	// a != b
	// a < b
	// a > b
	// a <= b
	// a >= b

}

procedures :: proc() {
	add :: proc(x: int, y: int) -> int {
		return x + y;
	}
	print_int(add(3, 4)); // 7
	print_rune('\n');

	add_v2 :: proc(x, y: int) -> int {
		return x + y;
	}


	swap_strings :: proc(x, y: string) -> (string, string) {
		return y, x;
	}
	a, b := swap_strings("Hellope\n", "World\n");
	print_string(a);
	print_string(b);

	a, b = b, a; // Quirk of grammar the of multiple assignments
	print_string(a);
	print_string(b);

	// Not hints, it's mandatory
	proc1 :: proc(a, b: int) #inline {
		print_int(a + b);
	}
	proc2 :: proc(a, b: int) #no_inline {
		print_int(a + b);
	}
}


TAU :: 6.28318530718;

constants :: proc() {
	TAU :: 6.28318530718; // untyped float
	WORLD_JAPANESE :: "世界"; // untyped string

	TAU_32 : f32 : 6.28318530718;
	TAU_AS_32 :: 6.28318530718 as f32;
}

nl :: proc() { print_rune('\n'); }

types :: proc() {

	x: int = 123;
	y := x; // y: int = x;
	// z: f32 = x; // invalid
	z: f32 = x as f32;

	ptr_z := ^z; // Pascal notation
	ptr_z^ = 123; // Derefence Notation
	print_f32(z); nl();

	// ^z - pointer to z
	// z^ - z from pointer

	f32_array: [12]f32; // Array of 12 f32
	f32_array[0] = 2;
	f32_array[1] = 3;
	// f32_array[-1] = 2; // Error - compile time check
	// f32_array[13]  = 2; // Error - compile time check
	f32_array_len := len(f32_array); // builtin procedure
	f32_array_cap := cap(f32_array); // == len(f32_array)

	api: [2]^f32;
	papi: ^[2]^f32;

	f32_slice: []f32; // Array reference
	f32_slice = f32_array[0:5];
	f32_slice = f32_array[:5];
	f32_slice = f32_array[:]; // f32_array[0:len(f32_array)-1];

	f32_slice = f32_array[1:5:7]; // low:1, high:5, capacity:7

	append_success := append(^f32_slice, 1);
	_ = append(^f32_slice, 2);

	_ = copy(f32_array[0:2], f32_array[2:4]); // You can use memcpy/memmove if you want


	s := "Hellope World";
	sub_string := s[5:10];

	v0: {4}f32; // Vector of 4 f32
	v0[0] = 1;
	v0[1] = 3;
	v0[2] = 6;
	v0[3] = 10;

	v1 := v0 + v0; // Simd Arithmetic
	v1 = v1 - v0;
	v1 *= v0; // i.e. hadamard product
	v1 /= v0;

	// builtin procedure
	v2 := swizzle(v0, 3, 2, 1, 0); // {10, 6, 3, 1}

	v3: {4}bool = v0 == v2;
	// LLVM rant?


	type Vec4: {4}f32;
	type Array3Int: [3]int;

	type Vec3: struct {
		x, y, z: f32
	}

	type BinaryNode: struct {
		left, right: ^BinaryNode, // same format as procedure argument
		data: rawptr,
	}

	type AddProc: proc(a, b: int) -> int

	type Packed: struct #packed {
		a: u8,
		b: u16,
		c: u32,
	}
	static_assert(size_of(Packed) == 7);


	{
		type MyInt: int
		x: int = 1;
		y: MyInt = 2;
		// z := x + y; // Failure - types cannot implicit convert*
		z := x as MyInt + y; // Type cast using `as`
	}


	{
		// From: Quake III Arena
		Q_rsqrt :: proc(number: f32) -> f32 {
			i: i32;
			x2, y: f32;
			THREE_HALFS :: 1.5;

			x2 = number * 0.5;
			y = number;
			i = (^y as ^i32)^;                      // evil floating point bit level hacking
			i = 0x5f3759df - i>>1;                  // what the fuck?
			y = (^i as ^f32)^;
			y = y * (THREE_HALFS - (x2 * y *y));    // 1st iteration
		//	y = y * (THREE_HALFS - (x2 * y *y));    // 2nd iteration, this can be removed
			return y;
		}

		Q_rsqrt_v2 :: proc(number: f32) -> f32 {
			THREE_HALFS :: 1.5;

			x2 := number * 0.5;
			y := number;
			i := y transmute i32;                   // evil floating point bit level hacking
			i = 0x5f3759df - i>>1;                  // what the fuck?
			y = i transmute f32;
			y = y * (THREE_HALFS - (x2 * y *y));    // 1st iteration
		//	y = y * (THREE_HALFS - (x2 * y *y));    // 2nd iteration, this can be removed
			return y;
		}

		// transmute only works if the size of the types are equal
		/{
			// in C
			union {
				i32 i;
				f32 y;
			};
		 }/
	}

	{ // Compound Literals
		a := [3]int{1, 2, 3};
		b := [3]int{};
		c := [..]int{1, 2, 3};

		d := []int{1, 2, 3}; // slice

		e := {4}f32{1, 2, 3, 4};
		f := {4}f32{1}; // broadcasts to all
		// g := {4}f32{1, 2}; // require either 1 or 4 elements

		type Vec2: {2}f32;

		h := Vec2{1, 2};

		i := Vec2{5} * h; // For strong type safety
		// FORENOTE: 5 * h was originally allowed but it was an edge case in the
		// compiler I didn't think it was enough to justify have it it.

		print_f32(i[0]); print_rune(',');
		print_f32(i[1]); print_rune('\n');
	}

	{
		do_thing :: proc(p: proc(a, b: int) -> int) {
			print_int(p(3, 4)); nl();
		}

		add :: proc(a, b: int) -> int {
			return a + b;
		}


		add_lambda := proc(a, b: int) -> int {
			return a - b;
		}; // note semicolon

		do_thing(add);
		do_thing(add_lambda);
		do_thing(proc(a, b: int) -> int {
			return a * b;
		});
	}

	{ // strings and runes
		escaped := "Hellope World\n";
		raw     := `Hellope World\n`;
		print_string(escaped);
		print_string(raw); nl();

		// Crap shader example
		shader_string :=
`#version 410

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec3 a_normal;
layout (location = 2) in vec2 a_tex_coord;

out vec3 v_position;
out vec3 v_normal;
out vec2 v_tex_coord;

uniform mat4 u_model_view;
uniform mat3 u_normal;
uniform mat4 u_proj;
uniform mat4 u_mvp;

void main() {
    v_tex_coord = a_tex_coord;
    v_normal = normalize(u_normal * a_normal);
    v_position = vec3(u_model_view * vec4(a_position, 1.0));

    gl_Position = u_mvp * vec4(a_position, 1.0);
}`;


		knot1 := '⌘';
		knot2 := '\u2318';     // 16 bit
		knot3 := '\U00002318'; // 32 bit
		knot4 := "\xe2\x8c\x98"; // Note it's a string, should I allow untyped string -> untyped rune casts?

		// String ideas "nicked" from Go, so far. I think I might change how some of it works later.
	}


	{ // size, align, offset
		type Thing: struct {
			a: u8,
			b: u16,
			c, d, e: u32,
		}

		s := size_of(Thing);
		a := align_of(Thing);
		o := offset_of(Thing, b);

		t: Thing;

		sv := size_of_val(t);
		av := align_of_val(t);
		ov := offset_of_val(t.b);
	}
}

data_control :: proc() {
	sum := 0;
	for i := 0; i < 12; i++ {
		sum += 1;
	}
	print_string("sum = "); print_int(sum); nl();

	sum = 1;
	for ; sum < 1000000; {
		sum += sum;
	}
	print_string("sum = "); print_int(sum); nl();

	sum = 1;
	for sum < 1000000 {
		sum += sum;
	}
	print_string("sum = "); print_int(sum); nl();

	// loop
	// for { } == for true {}

	// Question: Should I separate all these concepts and rename it?
	//
	// range - iterable
	// for   - c style
	// while
	// loop  - while true

	// Notes:
	// conditions _must_ a boolean expression
	// i++ and i-- are statements, not expressions


	x := 2;
	if x < 3 {
		print_string("x < 2\n");
	}

	// Unified initializer syntax - same as for statements
	if x := 2; x < 3 {
		print_string("x < 2\n");
	}

	if x := 4; x < 3 {
		print_string("Never called\n");
	} else {
		print_string("This is called\n");
	}

	{ // String comparison
		a := "Hellope";
		b := "World";
		if a < b {
			print_string("a < b\n");
		}
		if a != b {
			print_string("a != b\n");
		}

	}




	{
		defer print_string("日本語\n");
		print_string("Japanese\n");
	}

	{
		defer print_string("1\n");
		defer print_string("2\n");
		defer print_string("3\n");
	}

	{
		// C strings, yuk!
		to_c_string :: proc(s: string) -> ^u8 {
			c := heap_alloc(len(s)+1) as ^u8;
			mem_copy(c, ^s[0], len(s));
			c[len(s)] = 0;
			return c;
		}

		fopen  :: proc(filename, mode: ^u8) -> rawptr #foreign
		fclose :: proc(f: rawptr) -> i32 #foreign

		filename := to_c_string("../examples/base.odin");
		mode := to_c_string("rb");
		defer heap_free(filename);
		defer heap_free(mode);

		f := fopen(filename, mode);
		if f == null {
			// handle error
		}
		defer if f != null {
			_ = fclose(f);
		}

		// rest of code

		// Better version
		/{
			type File: struct { filename: string }
			type FileError: int
			open_file :: proc(filename: string) -> (File, FileError) { ... }
			close_file :: proc(f: ^File) { ... }
			f, err := open_file("Test");
			if err != 0 {
				// handle error
			}
			defer close_file(^f);

		}/


	}

	for i := 0; i < 100; i++ {
		blah := heap_alloc(100 * size_of(int)) as ^int;
		defer {
			defer print_string("!");
			defer print_string("heap_free");
			heap_free(blah);
		}

		if i == 3 {
			// defers called
			continue;
		}

		if i == 5 {
			// defers called
			return;
		}

		if i == 8 {
			// defers called
			break; // never happens
		}
	}

	defer print_string("It'll never happen, mate 1");
	print_string("It'll never happen, mate 2");
	print_string("It'll never happen, mate 3");
}

