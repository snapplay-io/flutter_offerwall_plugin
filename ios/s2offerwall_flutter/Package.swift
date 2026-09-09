// swift-tools-version: 5.9
// Swift Package Manager 용 매니페스트이다.
//
// CocoaPods 와 동시에 지원한다. 소스는 한 벌만 두고
// podspec 의 source_files 도 이 디렉토리를 가리키도록 되어 있으므로
// 파일을 옮기거나 추가할 때 양쪽을 따로 관리할 필요는 없다.
//
// 주의) SDK 버전을 올릴 때는 아래 s2offerwall 버전과 podspec 의 s.dependency 를 같이 올려야 한다.
//       SPM 은 git 태그로 해석하므로 ios_offerwall_sdk 저장소에 해당 태그가 먼저 올라가 있어야 한다.
import PackageDescription

let package = Package(
    name: "s2offerwall_flutter",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "s2offerwall-flutter", targets: ["s2offerwall_flutter"])
    ],
    dependencies: [
        // Flutter 툴이 빌드 시점에 생성해주는 로컬 패키지이다. (경로 고정)
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/snapplay-io/ios_offerwall_sdk.git", from: "1.0.34")
    ],
    targets: [
        .target(
            name: "s2offerwall_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "s2offerwall", package: "ios_offerwall_sdk")
            ],
            resources: []
        )
    ]
)
