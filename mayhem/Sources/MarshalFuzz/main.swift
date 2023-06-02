#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#elseif canImport(MSVCRT)
import MSVCRT
#endif

import Foundation
import Marshal

@_cdecl("LLVMFuzzerTestOneInput")
public func MarshalFuzz(_ start: UnsafeRawPointer, _ count: Int) -> CInt {
    let fdp = FuzzedDataProvider(start, count)

    do {
        if fdp.ConsumeBoolean() {
            let json = try JSONParser.JSONObjectWithData(fdp.ConsumeRandomData())
            let val: Int = try json.value(for: fdp.ConsumeRemainingString())
        } else {
            if var json = try JSONSerialization.jsonObject(with: fdp.ConsumeRemainingData()) as? [AnyObject] {
                try json.jsonData()
            }
        }
    }
    catch _ as MarshalError {
        return -1;
    }
    catch let e as NSError {
        if e.localizedDescription.contains("correct format") {
            return -1;
        }
        exit(EXIT_FAILURE);
    }
    catch let error {
        print(error)
        print(type(of: error))
        exit(EXIT_FAILURE)
    }
    return 0;
}